#!/usr/bin/env bash

# carrel2diagram.sh - a front-end to ./bin/carrel2json.py and ./bin/template2html.sh

# Eric Lease Morgan <emorgan@nd.edu>
# August 7, 2019 - first documentation


# configure
CARREL2JSON='./bin/carrel2json.py'
CARRELS='./library'
TEMPLATE2HTML='./bin/template2html-diagram.sh'

# sanity check
if [[ -z $1 || -z $2 ]]; then
	echo "Usage: $0 <carrel> <NN|NNS|NNP|NNPS>" >&2
	exit
fi

# get input 
CARREL=$1
POS=$2

# do the work and done
$CARREL2JSON --path="$CARRELS/$CARREL/pos/" --pos="$POS" --cooccur --weight=3 > "$CARRELS/$CARREL/etc/$CARREL.json"
$TEMPLATE2HTML $CARREL > "$CARRELS/$CARREL/htm/network-diagram.htm"
open "$CARRELS/$CARREL/htm/network-diagram.htm"
exit
