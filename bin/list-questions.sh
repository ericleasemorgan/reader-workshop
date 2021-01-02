#!/usr/bin/env bash

# list-questions.sh - given a study carrel, output all its questions; a front-end to list-questions.pl

# Eric Lease Morgan <emorgan@nd.edu>
# August 17, 2019 - while investigating Philadelphia as a place to "graduate"


CARRELS='./library'
LISTQUESTIONS='./bin/list-questions.pl'
TXT='txt/*.txt'

if [[ -z $1 ]]; then
	echo "Usage: $0 <carrel>"  >&2
	exit
fi

# get input
CARREL=$1

# do the work and done
find $CARRELS/$CARREL/$TXT | while read FILE; do echo $( basename $FILE .txt ); done | parallel $LISTQUESTIONS "$CARRELS/$CARREL" {}
exit
