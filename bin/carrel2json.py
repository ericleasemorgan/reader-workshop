#!/usr/bin/env python

# carrel2json.py - given the short name of a Distant Reader study carrel, output a JSON file denoting relationships between parts-of-speech

# originally written by Team JAMS (Aarushi Bisht, Cheng Jial, Mel Mashiku, and Shivam Rastogi) as a function call for the PEARC '19 Hack-a-thon
# re-written as a script by Eric Lease Morgan <emorgan@nd.edu>

# August  7, 2019 - first documentation
# August 17, 2019 - in preparation of creating an additional repository, removed harvesting of content


# configure
PUNCTUATION = '[!"#$%&()*+,-./:;<=>?@[\\]^_`{|}~\t\n]+'
MINIMUM = 2

# require
from itertools import combinations
from sklearn.metrics.pairwise import cosine_similarity
import argparse
import glob
import json
import numpy as np
import os
import pandas as pd
import re
import sys
import gensim

# initialize
puc = re.compile( PUNCTUATION )


def parse_args() :

	parser = argparse.ArgumentParser()
	parser.add_argument('--path', type=str, default='/export/reader/carrels/asymptomatic/pos', help='Path to POS files.')
	parser.add_argument('--pos', type=str, default='NN', help='POS tag to look at.')
	parser.add_argument('--weight', type=float, default=1, help='Minimum weight.')
	parser.add_argument('--cooccur', action='store_true', help='Use co-occurence as weight')
	parser.add_argument('--cosine', action='store_true', help='Use cosine similarity as weight')
	parser.add_argument('--pretrained', type=str, help='Pre-trained word vectors for cosine similarity')

	return parser.parse_args()


def get_vector(word, model):
	try:
		return model.wv[word]
	except:
		return np.zeros((300,))


def main(args):

	# slurp up the study carrel
	for path in glob.glob( os.path.join(args.path, '*.pos') ) :

		try    : df = pd.read_csv( path, sep='\t' )
		except : continue
		else   : break

	# Filter based on POS tag
	df_noun = df[ df[ 'pos' ] == args.pos ]
	number  = df_noun.lemma.value_counts()

	df_noun = df_noun[~df_noun.lemma.str.contains(puc)]
	clean_noun = list(df_noun.lemma.unique())
	result = dict.fromkeys(combinations(clean_noun, 2), 0)

	if args.cooccur:

		# count
		for i in df_noun.sid.unique() :
			temp = df_noun[ df_noun[ 'sid' ] == i ]
			for pair in combinations(temp.lemma.unique(), 2):
				if pair in result:
					result[pair] += 1
				else:
					result[pair[1], pair[0]] += 1
		result = pd.DataFrame.from_dict(result, orient='index', columns=['weight'])
		result['token1'] = [i[0] for i in result.index]
		result['token2'] = [i[1] for i in result.index]
		# result = result.reset_index().rename(columns={'index': 'nodepair'})
		
		# Threshold for link weight
		clean_result  = result[ result[ 'weight' ] > args.weight ]
		data          = {}
		data['nodes'] = []
		data['links'] = []

		for token in clean_noun :
			size = int( number.loc[ token ] )
			if size > MINIMUM: 
				data[ 'nodes' ].append({"id": token, "group": 1, "size": size})
		for row in clean_result.iterrows(): 
			data[ 'links' ].append({"source": row[1].token1, 
									"target": row[1].token2, 
									"value":  row[1].weight})

		# output
		print( json.dumps( data ) )
	
	if args.cosine:
		sys.stderr.write('Use cosine as link weight')
		model = gensim.models.KeyedVectors.load_word2vec_format(
			args.pretrained, binary=True
			)
		vector_clean_noun = np.array([get_vector(i, model) for i in clean_noun])
		similarity = cosine_similarity(vector_clean_noun)
		np.fill_diagonal(similarity, 0)
		
		for i, j, pair in zip(*(np.triu_indices(74, 1)), result.keys()):
			result[pair] = similarity[i, j]

		# Threshold for link weight
		clean_result  = result[ result[ 'weight' ] > args.weight ]
		data          = {}
		data['nodes'] = []
		data['links'] = []

		for token in clean_noun :
			size = int( number.loc[ token ] )
			if size > 0: 
				data[ 'nodes' ].append({"id": token, "group": 1, "size": size})
		for row in clean_result.iterrows(): 
			data[ 'links' ].append({"source": row[1].token1, 
									"target": row[1].token2, 
									"value":  row[1].weight})
		# output
		print( json.dumps( data ) )


if __name__ == "__main__":
	main(parse_args())