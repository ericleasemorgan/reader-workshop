#!/usr/bin/env perl


# configure
use constant DATA    => './etc';
use constant CARRELS => './library';

# require
use strict;

# get input
my $carrel = $ARGV[ 0 ];
if ( ! $carrel ) { die "Usage: $0 <carrel>\n" }

# open the metadata file, and process each field
my $file = DATA . "/$carrel.txt";
open METADATA, "< $file" or die "Can't open $file ($!)\n";
my %metadata = ();
while ( <METADATA> ) {

	# parse & update
	chop;
	my ( $name, $value ) = split( /\t/, $_ );
	$metadata{ $name }   = $value;
	
}
close METADATA;

# slurp up the template and do the necessary substitutions
my $metadata =  &template();
$metadata    =~ s/##SCOPENOTE##/$metadata{ 'SCOPENOTE' }/e;
$metadata    =~ s/##CREATOR##/$metadata{ 'CREATOR' }/e;
$metadata    =~ s/##EMAIL##/$metadata{ 'EMAIL' }/eg;
$metadata    =~ s/##CREATIONDATE##/$metadata{ 'CREATIONDATE' }/e;

# slurp up the HTML and do the necessary substitutions
my $html =  CARRELS . "/$carrel/index.htm";
$html    =  &slurp( $html );
$html    =~ s/Basic Reports/$metadata{ 'LONGNAME' }/e;
$html    =~ s/<!--##METADATA##-->/$metadata/e;

# output and done
print $html;
exit;


sub template {

	return <<EOF
<p>##SCOPENOTE##</p>
<p style='text-align: right'>##CREATOR## &lt;<a href='mailto:##EMAIL##'>##EMAIL##</a>&gt;<br />##CREATIONDATE##</p>
EOF

}

sub slurp {

	my $f = shift;
	open ( F, $f ) or die "Can't open $f: $!\n";
	my $r = do { local $/; <F> };
	close F;
	return $r;

}

