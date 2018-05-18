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
  -i <file>  embl file, required
  -t <file>  te id file, required
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
    my ($embl_id, $fb_id, $source_id, $species, $te_name) = split(',', $line);
    $hash{$embl_id} = $fb_id;
}
close ID;

while ( <IN> ) {
  if ($_ =~ m/^ID/i) {
    foreach my $key ( sort keys %hash ) {
     s/\s$key\s/ $hash{$key} /g;
    }
  }
  print OUT $_; 
}

close IN;
close OUT;