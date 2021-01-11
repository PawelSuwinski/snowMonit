# snowMonit
Simple parser of snow cover table from [hydro.imgw.pl](https://hydro.imgw.pl) website.


## Requirements
 
 - pdftotext >= 20.0.0 (poppler/poppler-utils package)
 - wget (full version for SSL support, tested with ^1.20)
 - busybox
 - bash


## Installation - Android

1. Install [Termux](https://termux.com) and Termux Widget add-on (from F-Droid).
Additionally for notification alerts install also Termux API and Termux Boot add-ons.

2. Open Termux and execute:

```
pkg install poppler bash wget busybox termux-tools
wget -q -O - https://raw.githubusercontent.com/PawelSuwinski/snowMonit/main/install.sh | bash
~/snow.sh -h
```

3. Add Termux Widget to desktop pointing to _snow_ shortcut.

4. Run Termux Boot once if cron job notification alerts was chosen.


## Usage example

### Show all stations with snow cover greater than 10cm

`./snow.sh -m 10`

### Show chosen stations

`./snow.sh milejewo chojnice`

### Send notification when cover meets requirements

Cronjob / termux-job-sheduler case.

```
MSG=$(./snow.sh -m 10 milejewo chojnice); [[ -n $MSG ]] && termux-notification -t WARUN <<< $MSG
```
