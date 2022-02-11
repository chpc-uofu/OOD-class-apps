#!/bin/bash

# this script needs to run as root

APPS="ATMOS5340 ATMOS_SYNOPTIC CHEN2450 CHEN_Jupyter GEOG5670_desktop MIB2020"
# other class apps in this repo are deprecated
DATE=`date +%Y-%m-%d`
BAKDIR="/var/www/ood/apps/sys-$DATE"

if [[ ! -d $BAKDIR ]]; then
  mkdir -p $BAKDIR
fi

for APP in $APPS
do
  echo Updating $APP
  mv /var/www/ood/apps/sys/$APP $BAKDIR
  ln -s /uufs/chpc.utah.edu/sys/ondemand/chpc-class/$APP .
done
