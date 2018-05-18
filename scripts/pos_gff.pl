#!/usr/bin/perl

use strict; use warnings; use Getopt::Long; use Data::Dumper;

# ------------------------------------------------------------------
# GetOptions
# ------------------------------------------------------------------
my ($fIn,$fOut);
GetOptions(
				"help|?" =>\&USAGE,
				"o:s"=>\$fOut,
				"i:s"=>\$fIn,
				) or &USAGE;
&USAGE unless ($fIn);

sub USAGE {#
	my $usage=<<"USAGE";
Description:	this program is used to modify GFF file from embl_to_fa_gff.pl
Usage:
  Options:
  -i <file>  input file, required
  -o <file>  output file, not required  
  -h         Help

USAGE
	print $usage;
	exit;
}

open (IN, '<', $fIn) or die $!;

if ($fOut) {
    open (OUT, '>', $fOut);
} else {
    open(OUT, ">&STDOUT");
}

my @headers;
my @gfflines;

while (<IN>) {
    chomp $_;
    if ($_ =~ m/(sequence-region|gff-version)/) {  
        push (@headers, $_);
    } else {
        push (@gfflines, $_);
    }
}
close IN;

print OUT "$_\n" for (@headers);
print OUT "$_\n" for (@gfflines);


# while (my $line = <IN>) {
# 	push (@lines, $line);
# }