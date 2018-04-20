#! /usr/bin/perl

use warnings;
use strict;
use Getopt::Long;
use Bio::SeqIO;
#use LFasta;
#use LFastaIO;
use Bio::Tools::GFF;

# Documentation

use constant USAGE =><<END;

SYNOPSIS:

 reformat.pl [OPTIONS] [input file [output file]]

DESCRIPTION:

This script does reformatting from EMBL to fasta sequence formats.

OPTIONS:

        --informat
              Specifies input format. If format is not specified
              the script takes pains to gues it.
        --outformat
              Specifies output format. If format is not specified
              the script takes pains to gues it.

EXAMPLES:

 # Standard reformatting:

 reformat.pl file.embl file.fasta

 reformat.pl --informat embl --outformat fasta file1 file2

AUTHOR:

Shunhua Han

COPYRIGHT:

This program is free software. You may copy and redistribute it under
the same terms as Perl itself.

END

# Options and Args

my $informat = '';
my $outformat = '';
my $gffversion = 3;
my $help = 0;
my $gff = '';

GetOptions("informat=s" => \$informat,
           "outformat=s" => \$outformat,
           "help" => \$help) or die USAGE;

$help and die USAGE;
# Get the infiles and outfiles if specified as arguments:
my $infile = shift @ARGV if @ARGV;
my $outfile = shift @ARGV if @ARGV;


# Guess format and check for wrong options

$informat = guessformat($informat ? $informat : $infile) or
  die "Could not guess informat.\n";
$outformat = guessformat($outformat ? $outformat : $outfile) or
  die "Could not guess outformat.\n";


# Create the input file handle:
my $in;
if ($infile) {
  eval{
    $in = Bio::SeqIO->newFh(-file => "$infile",
                            -format => $informat )
  }; die handle_exception($@) if $@;
} else {
  eval{
    $in = Bio::SeqIO->newFh(-fh => \*STDIN ,
                            -format => $informat )
  }; die handle_exception($@) if $@;
}

# Create the output file handle:
my $out;
if ($outfile) {
  if ($outformat =~ /gff/i) {
    open $out, ">/dev/null" or die;
    $gff = $outfile;

  } else {
      eval{
        $out = Bio::SeqIO->newFh(-file => ">$outfile",
                                -format => $outformat )
      }; die handle_exception($@) if $@;
  }
} else {
  if ($outformat =~ /gff/i) {
    open $out, ">/dev/null" or die;
    $gff = '&STDOUT';

  } else {
      eval{
      $out = Bio::SeqIO->newFh(-fh => \*STDOUT,
                               -format => $outformat )
    }; die handle_exception($@) if $@;
  }
}

my $gffout;
if ($outformat =~ /gff/i) {
  open $gffout, ">$gff" or die "$gff: $!\n";
  print $gffout "##gff-version 3"
}

# Bioperl reformatting
while (my $seq = <$in>) {
  if ($gffout) {
    my $gfflines = get_gff_features($seq);
    print $gffout $_ for (@$gfflines);
  }
  # Print in the required format:
  print $out $seq;
}

sub get_gff_features {
  my $seq = shift;

  my @gfflines = ();
  my @features = $seq->all_SeqFeatures();

  my $gffio = Bio::Tools::GFF->new(-gff_version => $gffversion);

  for my $f (@features) {
    my $id = $seq->id;
    my $gff = $gffio->_gff3_string($f);

    $gff =~ s/^SEQ/$id/mg;
    push @gfflines, "$gff\n";
  }

  return \@gfflines;
}


sub guessformat {
  my $s = shift @_;

  # If the string has a '.' then it is probably a filename, and then
  # we just consider the suffix:
  $s =~ /[^\.]+$/;
  $s = $&;

  my $format = 0;
 SW: {
    if ($s =~ /(^fasta)|(^fast)|(^fst)|(^fsa)|(^ft)|(^fs)|(^fa)/i) {
      $format = 'Fasta'; last SW;
    }
    if ($s =~ /(^l(a(b(el(ed)?)?)?)?f(a(st(a)?)?)?)|(^lfst)|(^lfsa)|(^lft)|(^lfs)/i) {
      $format = 'LFasta'; last SW;
    }
    if ($s =~ /(embl)|(emb)|(em)|(eml)/i) {
      $format = 'EMBL'; last SW;
    }
    if ($s =~ /(genebank)|(genbank)|(genb)|(geneb)|(gbank)|(gb)/i) {
      $format = 'GenBank'; last SW;
    }
    if ($s =~ /(swissprot)|(sprt)|(swissp)|(sprot)|(sp)|(spr)/i) {
      $format = 'Swissprot'; last SW;
    }
    if ($s =~ /pir/i) {
      $format = 'PIR'; last SW;
    }
    if ($s =~ /gcg/i) {
      $format = 'GCG'; last SW;
    }
    if ($s =~ /scf/i) {
      $format = 'SCF'; last SW;
    }
    if ($s =~ /ace/i) {
      $format = 'Ace'; last SW;
    }
    if ($s =~ /phd/i) {
      $format = 'phd'; last SW;
    }
    if ($s =~ /phred/i) {
      $format = 'phred'; last SW;
    }
    if ($s =~ /raw/i) {
      $format = 'raw'; last SW;
    }
    if ($s =~ /gff/i) {
      $format = 'gff'; last SW;
    }
  }
  if (!$format && -e $s) {
    my $guesser = Bio::Tools::GuessSeqFormat->new(-file => $s);
    my $format  = $guesser->guess;
    $format ||= 0;
  }
  return $format;
}

sub handle_exception {
  my $exepts_str = shift;
  if ($@=~ /MSG:\s*(.*)/) {
    die "$1\n";
  } else {
    die $exepts_str;
  }
}