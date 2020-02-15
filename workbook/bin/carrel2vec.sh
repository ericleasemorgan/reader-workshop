#!/usr/bin/env bash

# documents2vec.sh - a front-end to documents2vec.py

# Eric Lease Morgan <eric_morgan@infomotions.com>
# October  17, 2018 - first documentation; written on a plane from Madrid to Chicago; brain-dead
# November 23, 2018 - added logic so a whole directory can be processed; baroque-en


# configure 
CARRELS='./library'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# get input
NAME=$1

# initialize
CARREL="$CARRELS/$NAME"
ETC="$CARREL/etc"
INDEX="$ETC/carrel.vec"
TXT="$CARREL/txt"
FILES=( $TXT/*.txt )
CARREL2VEC='./bin/carrel2vec.py'

# start from a clean slate
rm -rf $INDEX

# process each item in the list of files; baroque and rococo 
SIZE=${#FILES[@]}
for (( I=1; I<$SIZE+1; I++ )); do

	if [[ $I -eq 1 ]]; then
		COMMAND="$CARREL2VEC $NAME new ${FILES[$I-1]}"
	elif [[ $I -lt $SIZE+1 ]]; then
		COMMAND="$CARREL2VEC $NAME update ${FILES[$I-1]}"
	fi
  
  	# debug and do the work
  	echo "$I $COMMAND"
  	$COMMAND
  	
done

# close the index and done
COMMAND="$CARREL2VEC $NAME finish fini"
echo "$I $COMMAND"
$COMMAND
exit

