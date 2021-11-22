#!/data/data/com.termux/files/usr/bin/bash
#
# @author Paweł Suwiński, psuw@wp.pl
# @version 202101111900
# @url https://github.com/PawelSuwinski/snowMonit
# @licence MIT
# --------------------------------------------------

set -e

URL='https://res4.imgw.pl/products/hydro/monitor-lite-products/Pokrywa_sniezna.pdf'
TYPE=('' puszysty świeży krupiasty zsiadły zbity mokry szreń lodoszreń firn szadź)
FORMAT='%s:%.0s %.0f / %.0f [cm] %s\n'
DATETIME=$(date '+%Y%m%d%H%M%S')

[[ -z $TMPDIR ]] && TMPDIR='/tmp'
fileName="$(basename $0)-${DATETIME:0:8}"
filePath="$TMPDIR/$fileName"

usage() {
  cat <<EOT
Usage: $0 [-h] [-f FORMAT] [-m MIN] [-u URL] [location ...]

   -h        help
   -f FORMAT printf output format, default '$FORMAT',
             where respectively that are B, E, G, H, I columns
   -m MIN    minimum depth [cm]
   -u URL    data url, default: $URL

  location  location pcre pattern to match (case insensitive)

  Files:

    ${filePath}.pdf Downloaded PDF file
    ${filePath}.csv PDF parsed to CSV format
    ${filePath}.log Error and output log
EOT
}

# input options
while getopts "hf:m:u:" opt
do
  case $opt in
    h)
      usage && exit 0
      ;;
    m)
      [[ ! $OPTARG =~ ^[1-9][0-9]*$ ]] && \
        echo "MIN: integer value expected!" && exit 1
      MIN=$OPTARG
      ;;
    u)
      URL=$OPTARG
      ;;
    f)
      FORMAT=$OPTARG
      ;;
  esac
done
shift $((OPTIND-1))

# log session
exec 2>> "${filePath}.log"
echo $DATETIME >> "${filePath}.log"

# clean temp files older than one day
find $TMPDIR -name "${fileName%-*}-*" -mtime +1 -delete || true

# fetch pdf and parse to csv, force if data is old
sedCmd() {
  [[ -n $3 ]] && P=$3 || P='[^>]+'
  echo -n "s#.*left:${1}px.*>(${P})</p>#:${2}:\1#p"
}
val() { local V=${1##*:${2}:}; echo -n "${V%%:*}"; }
getDate() { local DATE; read DATE < "${filePath}.csv"; echo -n $DATE; }
[[ ! -s "${filePath}.csv" || $(getDate) != ${DATETIME:0:8} ]] &&
  wget -a "${filePath}.log" -O "${filePath}.pdf" "${URL}" &&
  pdftohtml -i -s -stdout "${filePath}.pdf" | sed -nr \
    -e 's/&#160;/ /g' \
    -e 's/.*([0-9]{2})\.([0-9]{2})\.([0-9]{4}).*/:DATE:\3\2\1/p' \
    -e "$(sedCmd '[3-5][0-9]' 'B')" \
    -e "$(sedCmd '4[1-2][0-9]' 'E')" \
    -e "$(sedCmd '5[4-9][0-9]' 'G' '[0-9]+,[0-9]+')" \
    -e "$(sedCmd '6[0-4][0-9]' 'H' '[0-9]+(,[0-9]+)?')" \
    -e "$(sedCmd '6[5-7][0-9]' 'I' '[0-9]')" |
  tr -d "\n" | sed 's/:B:/\n/g' | while read row; do
    [[ -z $DATE && $row == *:DATE:[0-9]* ]] &&
      val "$row" 'DATE' && echo
    [[ $row == *:G:[0-9]* ]] && G=$(val "$row" 'G') || G=0
    [[ $row == *:H:[0-9]* ]] && H=$(val "$row" 'H') || H=0
    [[ $G =~ ^0(,0)?$ && $H =~ ^0(,0)?$ ]] && continue
    [[ $row == *:E:* ]] && E=$(val "$row" 'E') || E=''
    [[ $row == *:I:[0-9]* ]] && I=$(val "$row" 'I') || I=0
    B=${row%%:*}; [[ $B == Ł* ]] && B=${B/Ł/L}; [[ $B == Ś* ]] && B=${B/Ś/S}
    echo "$B;$E;$G;$H;$I"
  done | sort > "${filePath}.csv"

# parse output
parse() {
  local DATE; read DATE;
  LC_NUMERIC=C
  IFS=';'; while read B E G H I; do
    [[ -n $MIN && ${G%,*} -lt $MIN && ${H%,*} -lt $MIN ]] && continue
    [[ -n $DATE ]] && echo $DATE && unset DATE
    printf "$FORMAT" "$B" "$E" "${G/,/.}" "${H/,/.}" "${TYPE[$I]}"
  done
}
[[ -z $1 ]] && parse < "${filePath}.csv" ||
  grep -iE "(^[1-9][0-9]+\$|$(IFS='|'; echo -n "$*"))" "${filePath}.csv" | parse
