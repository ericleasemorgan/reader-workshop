#!/usr/bin/env perl

# compare.pl - calculate the sameness of two documents; see: http://nlp.stanford.edu/IR-book/html/htmledition/dot-products-1.html

# Eric Lease Morgan <eric_morgan@infomotions.com>
# April 15, 2009 (Tax Day) - first cut
# April 16, 2009           - abstracted; included great ideas; compared many documents
# April 17, 2009           - moved compare to subroutines.pl
# December 2, 2009         - gave command-line input

# uses cosine similarity defined as:
#   cos( ( a.b ) / ( ||a|| * ||b|| ) )
#
# i.e. two documents with three dimensions and corresponding scores
#
#                 plato (a)  aristotle (b)
#    justice (1)    0.996       0.993
#  democracy (2)    0.087       0.120
#  statehood (3)    0.017       0.000


# use/require
use Lingua::StopWords qw( getStopWords );
use strict;
require './etc/tfidf-toolbox.pl';

# sanity check
my $directory = $ARGV[ 0 ];
my $lexicon   = $ARGV[ 1 ];
if ( ! $directory || ! $lexicon ) { die "Usage: $0 <directory> <lexicon>\n" }

# initialize
$|               = 1;
my @corpus       = &corpus( $directory );
my $ideas        = &slurp_words( $lexicon );
my $stopwords    = &getStopWords( 'en' );
my %comparisons = ();

# header
print "\tComparison: scores closer to 1000 approach similarity\n\n\t";
for ( my $d = 0; $d <= $#corpus; $d++ ) { print "\td", $d + 1 }
print "\n\n";

# compare each document...
my $index = 0;
for ( my $a = 0; $a <= $#corpus; $a++ ) {

	print "\td", $a + 1;
	
	# ...to every other document
	for ( my $b = 0; $b <= $#corpus; $b++ ) {

		# avoid redundant comparisions
		if ( $b <= $a ) { print "\t - " }
		
		# process next two documents
		else {
										
			# (re-)initalize
			my @books = sort( $corpus[ $a ], $corpus[ $b ] );
			
			# do the work; scores closer to 1000 approach similarity
			my $score = int(( &compare( [ @books ], $stopwords, $ideas, $directory )) * 1000 );
			$comparisons{ $corpus[ $a ] . ':' . $corpus[ $b ] } = $score;
			print "\t", $score;
			$index++;
			
			
		}
		
		#last if ( $index == 1000 );
		
	}
	
	# next line
	print "\n";

}

# display sorted list of comparisons
my $directory = $directory;
foreach ( sort { $comparisons{ $b } <=> $comparisons{ $a } } keys %comparisons ) {

	my $key = $_;
	$key =~ s/$directory\///eg;
	print $key, "\t" . $comparisons{ $_ }, "\n";

}

# display key
print "\n";
for ( my $d = 0; $d <= $#corpus; $d++ ) { print "\td", $d + 1, ' = ' , $corpus[ $d ], "\n" }
print "\n";

exit;
