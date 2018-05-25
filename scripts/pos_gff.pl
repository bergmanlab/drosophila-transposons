#!/usr/bin/perl

use strict; use warnings; use Getopt::Long; use Data::Dumper;

# ------------------------------------------------------------------
# GetOptions
# ------------------------------------------------------------------
my ($fIn,$fIn2,$fOut);
GetOptions(
				"help|?" =>\&USAGE,
				"o:s"=>\$fOut,
				"i:s"=>\$fIn,
                "t:s"=>\$fIn2,
				) or &USAGE;
&USAGE unless ($fIn and $fIn2);

sub USAGE {#
	my $usage=<<"USAGE";
Description:	this program is used to modify GFF file from embl_to_fa_gff.pl
Usage:
  Options:
  -i <file>  input file, required
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

my @headers;
my @gfflines;
my %hash_type;
my %hash_source;
my %hash_name;

#read line of TE file from standard input
while (my $line = <ID>) {
    my ($embl_id, $fb_id, $source_id, $fb_name, $species, $te_name, $type_gff, $type_fasta, $subtype_fasta) = split(',', $line);
    $hash_type{$fb_id} = $type_gff;
    $hash_source{$fb_id} = $source_id;
    $hash_name{$fb_id} = $fb_name;
}
close ID;

while (<IN>) {
    chomp $_;
    if ($_ =~ m/gff-version/) {
        push (@headers, $_);
    } elsif ($_ =~ m/sequence-region/) {
        my ($seqreg, $fb_id, $start, $end) = split(' ', $_);
        my $comment;
        my $source = $hash_source{$fb_id};
        my $fb_name = $hash_name{$fb_id};
        if ($source !~ m/nnn/) {
            $comment = "ID=$fb_id;name=$fb_name;source=$source";
        } else {
           $comment = "ID=$fb_id;name=$fb_name"; 
        }
        my $master = join("\t", $fb_id, ".", $hash_type{$fb_id}, $start, $end, ".", ".", ".", ".", $comment);
        push (@headers, $_);
        push (@gfflines, $master);
    } else {
        push (@gfflines, $_);
    }
}
close IN;

print OUT "$_\n" for (@headers);
print OUT "$_\n" for (@gfflines);
