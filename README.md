# snowMonit
Simple parser of snow cover table from [hydro.imgw.pl](https://hydro.imgw.pl) website.


## Requirements
 
 - pdftotext >= 20.0.0 (poppler/poppler-utils package)
 - wget (full version for SSL support, tested with ^1.20)
 - sed, grep, find, sort, tr, date, basename (standalone or busybox)
 - bash


## Installation 

Android [termux](https://termux.com) shell:

```
pkg install poppler bash wget busybox
wget https://raw.githubusercontent.com/PawelSuwinski/snowMonit/main/snow.sh
chmod a+x snow.sh
./snow.sh -h
```

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
