#!/usr/bin/perl

# measure-lexicon.pl - given a directory of text files and a lexicon, output tfidf scores

# Eric Lease Morgan <eric_morgan@infomotions.com>
# December 8, 2018 - first cut


# define
use constant STOPWORDS => './etc/stopwords.txt';

# use/require
use strict;
require './etc/tfidf-toolbox.pl';

# get the input
my $directory = $ARGV[ 0 ];
my $lexicon   = $ARGV[ 1 ];
if ( ! $directory or ! $lexicon ) { die "Usage: $0 <directory> <lexicon>\n" }

# initialize
my %index   = ();
my @corpus  = &corpus( $directory );
my $lexicon = &slurp_words( $lexicon );

# index the corpus
foreach my $file ( @corpus ) { $index{ $file } = &index( $file, &slurp_words( STOPWORDS ) ) }

# measure tfidf for each item in the lexicon
my $measurements = &measure( \%index, [ @corpus ], $lexicon );

# output a header for a tsv file
my @columns = ( 'file' );
foreach ( sort( keys( %$lexicon ) ) ) { push( @columns, $_ ) }
print join( "\t", @columns ), "\n";

# process each file
foreach my $file ( keys( %$measurements ) ) {

	# re-initialize the record's value
	my @fields = ( $file );
	
	# get the words/scores from the measurement, and process each one
	my $ideas = $$measurements{ $file };
	foreach my $idea ( sort( keys( %$ideas ) ) ) {
		
		# build the record
		push( @fields, $$ideas{ $idea } );
	
	}
	
	# output
	print join( "\t", @fields ), "\n";
	
}
	
# done, even more fun with tfidf
exit;


