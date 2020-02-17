#!/usr/bin/env bash

# harvest.sh - given the short name of a study carrel, cache it locally


LIBRARY='./library'
TMP='./tmp'
URL='http://carrels.distantreader.org/library'
ZIP='study-carrel.zip'

if [[ -z $1 ]]; then
	echo "Usage: $0 <short-name>" >&2
	exit
fi

CARREL=$1

mkdir -p $TMP
wget -O $TMP/$CARREL.zip $URL/$CARREL/$ZIP
rm -rf $LIBRARY/$CARREL
mkdir -p $LIBRARY/$CARREL
ROOT=$( unzip -Z $TMP/$CARREL.zip | sed -n 3p | tr -s ' ' | cut -d ' ' -f9 )
unzip -u $TMP/$CARREL.zip -d $TMP
cp -R  $TMP/$ROOT $LIBRARY/$CARREL
rm -rf $TMP/$ROOT
