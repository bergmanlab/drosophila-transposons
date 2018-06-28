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
my %hash_type_main;
my %hash_type_comment;
my %hash_subtype;
my %hash_source;
my %hash_name;

#read line of TE file from standard input
while (my $line = <ID>) {
		chomp $line;
    my ($embl_id, $fb_id, $source_id, $fb_name, $species, $te_name, $type_gff, $type_fasta, $subtype_fasta) = split(',', $line);
    $hash_type_main{$fb_id} = $type_gff;
    $hash_type_comment{$fb_id} = $type_fasta;
    $hash_subtype{$fb_id} = $subtype_fasta;
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
        my $comments;
        my $source = $hash_source{$fb_id};
        my $fb_name = $hash_name{$fb_id};
        my $te_type_main = $hash_type_main{$fb_id};
        my $te_type_comment = $hash_type_comment{$fb_id};
        my $te_subtype = $hash_subtype{$fb_id};
        if ($source !~ m/nnn/) {
            $comments = "ID=$fb_id;name=$fb_name;source=$source;type=$te_type_comment;subtype=$te_subtype";
        } else {
           $comments = "ID=$fb_id;name=$fb_name;type=$te_type_comment;subtype=$te_subtype";
        }
        my $master_line = join("\t", $fb_id, ".", $te_type_main, $start, $end, ".", ".", ".", $comments);
        push (@headers, $_);
        push (@gfflines, $master_line);
    } else {
        push (@gfflines, $_);
    }
}
close IN;

print OUT "$_\n" for (@headers);
print OUT "$_\n" for (@gfflines);
