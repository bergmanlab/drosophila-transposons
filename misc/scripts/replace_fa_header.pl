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
&USAGE unless ($fIn and $fIn2);

sub USAGE {#
	my $usage=<<"USAGE";
Description:	this program is used to replace embl id with flybase id
Usage:
  Options:
  -i <file>  fasta file with flybase id in header, required
  -t <file>  te table, required
  -o <file>  output file, not required
  -h         Help

USAGE
	print $usage;
	exit;
}

open (IN, '<', $fIn) or die $!;
open (ID, '<', $fIn2) or die $!;
if ($fOut) {
    open (OUT, '>', $fOut);
} else {
    open(OUT, ">&STDOUT");
}

my %hash;

#read line of TE file from standard input
while (my $line = <ID>) {
	  chomp $line;
    my ($embl_id, $fb_id, $source_id, $fb_name, $species, $te_name, $type_gff, $type_fasta, $subtype_fasta) = split(',', $line);
    my $header="$te_name#$type_fasta/$subtype_fasta";
    $hash{$fb_id} = $header;
}
close ID;

while (<IN> ) {
  # chomp $_;
  foreach my $key ( sort keys %hash ) {
     s/$key/$hash{$key}/g;
  }
  print OUT $_; 
}

close IN;
close OUT;