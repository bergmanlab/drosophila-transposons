#!/usr/bin/perl

use strict; use warnings; use Getopt::Long; use Data::Dumper;

# ------------------------------------------------------------------
# GetOptions
# ------------------------------------------------------------------
my ($fIn,$fOut,$fIn2);
GetOptions(
				"help|?" =>\&USAGE,
				"o:s"=>\$fOut,
				"i:s"=>\$fIn,
        "t:s"=>\$fIn2,
				) or &USAGE;
&USAGE unless ($fIn and $fOut and $fIn2);

sub USAGE {#
	my $usage=<<"USAGE";
Description:	this program is used to replace embl id with flybase id
Usage:
  Options:
  -i <file>  embl file,forced
  -t <file>  te id file,forced
  -o <file>  output file,forced  
  -h         Help

USAGE
	print $usage;
	exit;
}

my %hash;

# open( my $TABLE, '<', "../current/te_id_table.tsv" );
open (IN, '<', $fIn) or die $!;
open (ID, '<', $fIn2) or die $!;
open (OUT, '>', $fOut) or die $!;


#read line of TE file from standard input
while (my $line = <ID>) {
	# chomp $_;
    my ($embl_id, $fb_id, $source_id) = split(' ', $line);
    $hash{$embl_id} = $fb_id;
}
close ID;

# print "Key: $_ and Value: $hash{$_}\n" foreach (keys%hash);

# open( my $EMBL_DATA, '<', "../current/transposon_sequence_set.embl.txt" );
# open( my $OUTPUT, '>', "../current/transposon_sequence_set.embl.id_replaced.txt" );

while ( <IN> ) {
  foreach my $key ( sort keys %hash ) {
     s/\b$key\b/$hash{$key}/g;
  }
  print OUT $_; 
}

close IN;
close OUT;