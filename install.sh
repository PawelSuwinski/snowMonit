[[ -z $BINDIR ]] && BINDIR=$HOME

echo 'Installing snow.sh parser...'
wget -q -O "$BINDIR/snow.sh" https://raw.githubusercontent.com/PawelSuwinski/snowMonit/main/snow.sh
chmod a+x snow.sh

echo 'Adding Termux Widget shortcut...'
[[ ! -d .shortcuts ]] && mkdir .shortcuts
cat <<EOT > .shortcuts/snow
#!/data/data/com.termux/files/usr/bin/bash
bash "$BINDIR/snow.sh" -m 10
read
EOT
chmod a+x .shortcuts/snow

echo Done.
