# snowMonit
Simple parser of snow cover table from [hydro.imgw.pl](https://hydro.imgw.pl) website.


## Requirements
 
 - pdftotext >= 20.0.0 (poppler/poppler-utils package)
 - wget (full version for SSL support, tested with ^1.20)
 - sed, grep, find, sort, tr, date, basename (standalone or busybox)
 - bash


## Installation - Android

1. Install [Termux](https://termux.com) and Termux Widget add-on.

2. Open Termux and execute:

```
pkg install poppler bash wget busybox
wget -q -O - https://raw.githubusercontent.com/PawelSuwinski/snowMonit/main/install.sh | bash
bash snow.sh -h
```

3. Add Termux Widget to desktop pointing to _snow_ shortcut.


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
