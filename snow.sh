#! /bin/bash
#
# @author Pawel Suwinski, psuw@wp.pl
# @version 202101071800
# @licence MIT
# --------------------------------------------------

set -e

URL='https://res4.imgw.pl/products/hydro/monitor-lite-products/Pokrywa_sniezna.pdf'

usage() {
  cat <<EOT
Usage: $0 [-h] [-f] [-m MIN] [-u URL] [station ...] 

   -h      help
   -f      skip cache and fetch pdf file
   -m MIN  mininum depth [cm]
   -u URL  data url, default: $URL

  station  pcre row pattern to match, ex. station name (case insensitive)
EOT
}

# input options 
while getopts "hfm:u:" opt
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
      FETCH=1
      ;;
  esac
done
shift $((OPTIND-1))

[[ -z $TMPDIR ]] && TMPDIR='/tmp'
FILE="$(basename $0)-$(date +%Y%m%d).pdf"
LOG="${FILE%.*}.log"

# PRCE pattern
PATTERN='^ +[0-9]'
[[ -n $1 ]] && PATTERN+=".*($(IFS='|'; echo "$*"))"


# log timestamp
date '+%Y%m%d%H%M%S' >> "$TMPDIR/$LOG" 

# clean temp files older than one day
find $TMPDIR -name "${FILE%-*}*" -mtime +1 -delete  &>> "$TMPDIR/$LOG"

# fetch pdf
[[ ! -s "$TMPDIR/$FILE" || -n $FETCH ]] && 
  wget -a "$TMPDIR/$LOG" -O "$TMPDIR/$FILE" "${URL}"

# parse pdf
pdftotext -layout "$TMPDIR/$FILE" - 2>> "$TMPDIR/$LOG" | grep  -iE "$PATTERN" |
  while read row; do echo ${row//  /;}; done  | tr -s ';' |
  while read row; do
    row=${row//; /;}; IFS=';' ROW=($row)
    [[ -n $MIN && ${ROW[6]%,*} -lt $MIN && ${ROW[7]%,*} -lt $MIN ]] && continue
    echo "${ROW[1]}: ${ROW[6]} / ${ROW[7]} [cm]"
  done 
