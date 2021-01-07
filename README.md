# snowMonit
Simple parser of snow cover table from [hydro.imgw.pl](https://hydro.imgw.pl) website.


## Requirements
 
 - pdftotext (poppler/poppler-utils  package)
 - wget (full version)
 - tr, grep, find (standalone from coreutils or busybox)
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
