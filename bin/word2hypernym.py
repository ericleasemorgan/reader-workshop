#!/usr/bin/env python

# word2hypernym.py - given a study carrel, output a frequencies list of broader (key)words

# configure
DB        = 'etc/reader.db' 
LIBRARY   = './library'
ADJECTIVE = "select lemma from pos where pos like 'A%' group by lemma order by count(lemma) desc;"
KEYWORD   = 'SELECT keyword FROM wrd GROUP BY keyword ORDER BY COUNT( keyword ) DESC;'
LEMMA     = "select lemma from pos group by lemma order by count(lemma) desc;"
NOUN      = "select lemma from pos where pos like 'N%' group by lemma order by count(lemma) desc;"
VERB      = "select lemma from pos where pos like 'V%' group by lemma order by count(lemma) desc;"

# require
from nltk.corpus import wordnet as wn
import sqlite3
import sys

# sanity check
if len( sys.argv ) != 3 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <carrel> <noun|verb|adjective|keyword|lemma>\n" )
	exit()

# get input
carrel = sys.argv[ 1 ]
type   = sys.argv[ 2 ]

# initialize
database    = LIBRARY + '/' + carrel + '/' + DB
frequencies = {} 

# get sql
if   ( type == 'adjective' ) : sql = ADJECTIVE
elif ( type == 'keyword' )   : sql = KEYWORD
elif ( type == 'lemma' )     : sql = LEMMA
elif ( type == 'noun' )      : sql = NOUN
elif ( type == 'verb' )      : sql = VERB
else :

	# error; output usage
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <carrel> <noun|verb|adjective|keyword|lemma>\n" )
	exit()

# connect to the study carrel and process search result
cursor = sqlite3.connect( database ).cursor()
for record in cursor.execute( sql ):
	
	# parse
	keyword = record[ 0 ]
	
	# try to do the work
	try :
		
		# get only the first broader term
		hypernym = wn.synsets( keyword )[ 0 ].hypernyms()[ 0 ].name().split( '.' )[ 0 ]
		
		# update the frequency list
		if ( hypernym in frequencies ) : frequencies[ hypernym ] += 1
		else : frequencies[ hypernym ] = 1
	
	# bogus because I'm not pythonic
	except : foo = 'bar'
		
# process each frequency
for key, value in sorted( frequencies.items(), key=lambda item : item[ 1 ], reverse=True ) : 
	
	# output
	print( "\t".join( [ str( value ), key ] ) )

# done
exit
