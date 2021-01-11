[[ -z $BINDIR ]] && BINDIR=$HOME
q() { echo -n "$1 "; read choice <&1; [[ -n $2 && -z $choice ]] && choice=$2 ; }

echo 'Installing snow.sh parser...'

wget -q -O $BINDIR/snow.sh https://raw.githubusercontent.com/PawelSuwinski/snowMonit/main/snow.sh
chmod a+x $BINDIR/snow.sh
termux-fix-shebang $BINDIR/snow.sh


echo 'Adding Termux:Widget shortcut...'

q 'Set snow MIN [10cm]: '
[[ $choice =~ ^(0|[1-9][0-9]+)$ ]] && MIN=$choice || MIN=10
q 'Set station filter [all]: '; STATIONS=$choice

[[ ! -d .shortcuts ]] && mkdir .shortcuts
cat <<EOT > .shortcuts/snow
#!/data/data/com.termux/files/usr/bin/bash

$BINDIR/snow.sh -m $MIN ${STATIONS[*]}
read
EOT
chmod a+x .shortcuts/snow


q 'Set crond job service [y/N]?' 'N'
[[ $choice != [yY] ]] && echo Done. && exit 0

q 'Set snow MIN [10cm]: '
[[ $choice =~ ^(0|[1-9][0-9]+)$ ]] && MIN=$choice || MIN=10
q 'Set station filter [chojnice milejewo]: ' 'chojnice milejewo'
STATIONS=$choice

[[ ! $(which termux-notification) ]] && pkg install termux-api

echo 'Adding crontab entry...'

( 
crontab -l 2> /dev/null | grep -v snowMonit
echo -n '*/30 8-15 * 1-5,10-12 * DATE=$(date +%Y%m%d); [[ -z $TMPDIR ]] && TMPDIR=/tmp; '
echo -n "SNOW='$BINDIR/snow.sh -m $MIN $STATIONS'; "
echo -n 'LCK=$TMPDIR/snow.sh-${DATE}.lck; [[ ! -e $LCK ]] && [[ $($SNOW) == ${DATE}* ]] && '
echo 'touch $LCK && $SNOW | termux-notification -t snowMonit' 
) | crontab - 2> /dev/null
 
echo 'Adding Termux:Boot crond service...'
[[ ! -d .termux/boot ]] && mkdir -p .termux/boot
cat <<EOT > .termux/boot/snow
#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock
[[ ! \$(pgrep -x crond) ]] && crond
EOT
chmod a+x .termux/boot/snow

pkill -x crond
.termux/boot/snow

echo Done.
