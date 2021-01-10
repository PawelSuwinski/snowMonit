wget -q -O snow.sh https://raw.githubusercontent.com/PawelSuwinski/snowMonit/main/snow.sh
chmod a+x snow.sh

[[ ! -d .shortcuts ]] && mkdir .shortcuts
cat <<<EOT > .shortcuts/snow
#!/data/data/com.termux/files/usr/bin/bash
bash ~/snow.sh -m 10
read
EOT
chmod a+x .shortcuts/snow
