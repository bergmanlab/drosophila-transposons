#! /usr/bin/perl

use warnings;
use strict;
use Getopt::Long;
use Bio::SeqIO;
#use LFasta;
#use LFastaIO;
use Bio::Tools::GFF;

# {{{ Documentation

use constant USAGE =><<END;

SYNOPSIS:

 reformat.pl [OPTIONS] [input file [output file]]

DESCRIPTION:

This script does reformatting between sequence formats. It handles
GenBank, EMBL, Fasta and all the other formats supported by
bioperl. In addition it formats to labeled fasta (lfa) which is the a
handy extention of the fasta format developed by Anders Krogh for use
in HMM training. The labeling is generated from the sequence features
in a manner directed by the --labelkey option. The information surplus
or deficit when formatting between rich formats like EMBL and Fasta
can be handled by using the gff option. This specifies a gff file that
is read from or written to depending on the which way the formatting
goes.

OPTIONS:

        --informat
              Specifies input format. If format is not specified
              the script takes pains to gues it.
        --outformat
              Specifies output format. If format is not specified
              the script takes pains to gues it.
        --labelkey
              Associates features with a labeling key based of the
              primary tag in the feature annotation. Eg. 'exon:C
              intron:I defult:N'. The default key defaults to
              '-'. Note that in the where more than one of the
              specified features cover a base, the first one is always
              chosen. This way nesting of features can be controled to
              some extent. The special 'shadow' tag can be given as
              eg. shadow:S and controls which features on the minus
              strand that may produce a shadow label on the plus
              strand. Only the features listed after the shadow tag
              will produce shadowing. Note that the shadow tag is only
              used when formatting to Labeled Fasta. If the option is
              not given, the labelkey defaults to CDS:C exon:E
              intron:I intron:0 intron:1 intron:2 5\'UTR:5 3\'UTR:3
              poly-A:A
        --useaccession
              For use with reformating from a 'richseq' to
              Fasta. Makes onlythe accesion number from the 'richseq'
              appear as the id in the generated Fasta entry.
        --gff <filename>
              Specifies a GFF file to read from or write to depending
              on whether you are reformating from Fasta to a format
              holding sequence features or the other way around. If
              you want to use standard input of standard output, you
              can give '&STDIN' or '&STDOUT' as argument.
        --gffversion <int>
              Version of GFF to use. Default is 3. Can only be 2 or 3.
        --labelgroups "<groupname>:<labelstring> ..."
             Specifies grouping by parent field. Same notation as for
             labelkey (see example)
        --labelprefix <regex>
             Regular expression for the lines in each Labeled Fasta
             entry to process.
        --help
             Prints this help.
        --revcompl
              Reverse complments the entry and all the associated
              feature information.
        --allplus <feature>
              Reverse complments the entry and all the associated
              feature information if a <feature> is on the minus
              strand. Handy in making HMM training sets where the CDSs
              have to be on the forward strand. In case of CDSs on
              both strands it no reverse complementation is done.
        --trainingset
              Convenience option. Same as "-outformat LFasta
              -allplus CDS -labelkey 'CDS:C intron:I default:x"
        --help
              Produces this help.

EXAMPLES:

 # Standard reformatting:

 reformat.pl file.gb file.embl

 reformat.pl --informat fasta --outformat genbank file1 file2

 # this is equivalent to:

 reformat.pl -in fa -out gb file1 file2

 cat file.gb | reformat.pl -in gb -out embl > file.embl

 # GFF stuff:
 # This will write GFF lines to file.gff

 reformat.pl -gff file.gff file.embl file.fa

 # This will read GFF lines from file.gff

 reformat.pl -gff file.gff file.fa file.embl

 # This will print GFF lines to file.gff

 reformat.pl -gff file.gff file.embl file.fa

 # This will format to gff

 cat file.embl | reformat.pl -in embl -out gff > file.gff

 # Labeled Fasta stuff:

 reformat.pl --labelkey "intron:I 5'UTR:5 shadow:S CDS:C" file.gb file.lfa

 reformat.pl --labelkey "exon:E" -labelgr "transcript:EI" file.lfa file.gb

 reformat.pl file.lfa file.embl

DEPENDENCIES:

The classes: LFasta LFastaIO SeqFunctions. These are not on CPAN but
if you send me and email (kasper at binf.ku.dk) I will be more than happy
the send them.

AUTHOR:

Kasper Munch

COPYRIGHT:

This program is free software. You may copy and redistribute it under
the same terms as Perl itself.

END

# }}}

# {{{ Options and Args

my $informat = '';
my $outformat = '';
my $labelkey = "CDS:C exon:E intron:I";
my $trainingset = 0;
my $allplus = '';
my $revcompl = 0;
my $useaccession = 0;
my $useid = 0;
my $help = 0;
my $gff = '';
my $gffversion = 3;
my $labelgroups = '';
my $labelprefix = '#|0';

GetOptions("informat=s" => \$informat,
           "outformat=s" => \$outformat,
           "labelkey=s" => \$labelkey,
           "useaccession" => \$useaccession,
           "useid" => \$useid,
           "trainingset" => \$trainingset,
           "revcompl" => \$revcompl,
           "allplus=s" => \$allplus,
           "gff=s" => \$gff,
           "gffversion=i" => \$gffversion,
           "labelgroups=s" => \$labelgroups,
           "labelprefix=s" => \$labelprefix,
           "help" => \$help) or die USAGE;

$allplus =~ /^-/ and die "Did you forget to specify a value for --allplus?\n";

if ($trainingset) {
  $labelkey = 'CDS:C intron:I default:x';
  $allplus = 'CDS';
  $outformat = 'LFasta';
}

$useid and $useaccession and die "Don't use --useid with --useaccession\n";

$help and die USAGE;

# Get the infiles and outfiles if specified as arguments:
my $infile = shift @ARGV if @ARGV;
my $outfile = shift @ARGV if @ARGV;

# }}}

# {{{ Guess format and check for wrong options

$informat = guessformat($informat ? $informat : $infile) or
  die "Could not guess informat.\n";
$outformat = guessformat($outformat ? $outformat : $outfile) or
  die "Could not guess outformat.\n";

# if ($informat eq 'LFasta' && ($outformat =~ /GenBank|EMBL|SwissProt/ && !$labelkey)) {
#   die "You have to use the --labelkey option when formatting from LFasta\n",
#     "to another rich sequence format (GenBank, EMBL, SwissProt)\n";
# }
# if ($informat eq 'Fasta' && $gff  && $outformat eq 'LFasta' && !$labelkey) {
#   die "You have to use the --labelkey option when creating LabeledFasta from Fasta and GFF\n";
# }
# if ($outformat eq 'LFasta' && $informat =~ /GenBank|EMBL|SwissProt/ && !$labelkey) {
#   die "You have to use the --labelkey option when formatting from rich sequence\n",
#     "format (GenBank, EMBL, SwissProt)to LFasta\n";
# }
# if ($outformat eq 'Fasta' && $gff  && $informat eq 'LFasta' && !$labelkey) {
#   die "You have to use the --labelkey option when dumping GFF lines from LabeledFasta\n";
# }

# }}}

# {{{ IO

my $in;
if ($infile) {
  if ($informat eq 'LFasta') {
    eval{
      $in = LFastaIO->new(file => $infile);
    }; die handle_exception($@) if $@;
  } else {
    eval{
      $in = Bio::SeqIO->newFh(-file => "$infile",
                              -format => $informat )
    }; die handle_exception($@) if $@;
  }
} else {
  if ($informat eq 'LFasta') {
    eval{
      $in = LFastaIO->new(fh => \*STDIN)
    }; die handle_exception($@) if $@;
  } else {
    eval{
      $in = Bio::SeqIO->newFh(-fh => \*STDIN ,
                              -format => $informat )
    }; die handle_exception($@) if $@;
  }
}

# Create a the output file handle:
my $out;
if ($outfile) {
  if ($outformat =~ /gff/i) {
    open $out, ">/dev/null" or die;
    $gff = $outfile;

  } elsif ("$informat $outformat" =~ /LFasta/i) {
    eval{
      $out = LFastaIO->new(-file => ">$outfile",
                           -outformat => $outformat )
    }; die handle_exception($@) if $@;
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

  } elsif ("$informat $outformat" =~ /LFasta/i) {
    eval{
      $out = LFastaIO->new(-fh => \*STDOUT,
                           -outformat => $outformat )
    }; die handle_exception($@) if $@;
  } else {
    eval{
      $out = Bio::SeqIO->newFh(-fh => \*STDOUT,
                               -format => $outformat )
    }; die handle_exception($@) if $@;
  }
}

my $gffin;
my $gffout;
my %gffhash;
if ($gff && $informat =~ /Fasta/ && $outformat =~ /(EMBL)|(GenBank)|(SwissProt)|(LFasta)/) {
  open $gffin, "$gff" or die "$gff: $!\n";
  while (my $l = <$gffin>) {
    my @gff = split /\t/, $l;
    push @{$gffhash{$gff[0]}}, $l;
  }
} elsif ($gff && $outformat =~ /Fasta/ && $informat =~ /(EMBL)|(GenBank)|(SwissProt)|(LFasta)/) {
  open $gffout, ">$gff" or die "$gff: $!\n";
} elsif ($outformat =~ /gff/i) {
  open $gffout, ">$gff" or die "$gff: $!\n";
}

# }}}

# {{{ Bioperl reformatting

if ("$informat $outformat" !~ /LFasta/) {
  while (my $seq = <$in>) {

    if ($useaccession) {
      # Use accesion number for ID if that is asked for:
      my $acc = $seq->accession_number();
      unless ($acc) {
        warn "No accession number. Skipping...\n";
        next;
      }
      $seq->id($seq->accession_number());
    } elsif ($useid) {      
      # Use ID for accession number if asked for:
      my $id = $seq->id();
      unless ($id) {
        warn "No ID. Skipping...\n";
        next;
      }
      $seq->accession_number($seq->id());
    }

    # No whitespace in ids:
    if ($seq->id =~ /\s/) {
      if ($useaccession) {
        warn "White space in Accession: \"", $seq->id,"\" skipping entry...\n";
      } else {
#        warn "White space in ID: \"", $seq->id, "\" skipping entry...\n";
	warn "White space in ID: \"", $seq->id, "\" (accession: ", $seq->accession_number(), ") skipping entry...\n";
      }
      next;
    }

    $seq = revcomplseq($seq) if $revcompl;

    $revcompl && $allplus
      and die "Options --revcompl and --allplus are incompatible.\n";

    if ($allplus) {
      my $plus = 0;
      my $minus = 0;
      my @features = $seq->all_SeqFeatures();
      foreach my $f (@features) {
        if ($f->primary_tag() eq $allplus) {
          if (ref($f->location()) eq 'Bio::Location::Split') {
            my @sl = $f->location->sub_Location();
            if ($sl[0]->strand() eq '-1') {
              $minus = 1;
            } else {
              $plus = 1;
            }
          } else {
            if ($f->strand() eq '-1') {
              $minus = 1;
            } else {
              $plus = 1;
            }
          }
        }
      }
      if ($minus && !$plus) {
        $seq = revcomplseq($seq);
      }
    }

    if ($gffout) {
      my $gfflines = get_gff_features($seq);
      print $gffout $_ for (@$gfflines);
    } elsif ($gffin) {
      $seq->accession_number($seq->id);
      add_gff_features($seq);
    }

    # Print in the required format:
    print $out $seq;
  }
}

# }}}

# {{{ From Labeled Fasta

elsif ($informat eq 'LFasta') {

  if ($revcompl or $allplus) {
    die "You can't reverse-complement Labeled Fasta.\n";
  }

  while (my $lfa = <$in>) {
    if ($labelprefix) {
      $lfa->labelprefix($labelprefix);
    }
    if ($labelkey) {
      # We turn the hash around because we want the labels as keys:
      my %tmp = ( split /[:\s]+/, $labelkey );
      my %labelkey = ();
      while ( my ($key, $value) = each %tmp) {
        $labelkey{$value} = $key;
      }
      $lfa->labelkey(\%labelkey);
    }
    if ($labelgroups) {
      my %tmp = ( split /[:\s]+/, $labelgroups );
      my %labelkey = ();
      while ( my ($key, $value) = each %tmp) {
        $labelkey{$value} = $key;
      }
      $lfa->labelgroups(\%labelkey);
    }
    if ($gff && $gffout) {
       my $gfflines = $lfa->get_gff_features();
       print $gffout $_ for (@$gfflines);
    }
    print $out $lfa;
  }
}

# }}}

# {{{ To Labeled Fasta

elsif ($outformat eq 'LFasta') {

  # Ok, we have to do labeled fasta, so lets se if there is a key:
  my $keystr = $labelkey or die "\n";
  my @keys = split(/\s+/, $keystr);
  my %labels;
  my %features;
  my @regex;
  my @inputfeatures;
  my @shadowfeatures;
  my $shadowing = 0;
  for my $k (@keys) {
    my ($key, $value) = split(/:/, $k);
    $labels{$key} = $value;
    $features{$value} = $key;
    push @regex, "($key)" unless $key eq 'default';
    push @inputfeatures, $key;
    $shadowing = 1 if $key =~ /shadow/i;
    push @shadowfeatures, $key if $shadowing;
  }
  $labels{default} ||= '-';

  # Make a regular expression to look for features:
  my $regex = join('|', @regex);

  # we only label features included in the key Eg. 'coding:C
  # intron:I'. No space around ':'
 SEQ: while (<$in>) {
    my $seq = $_;

    # No whitespace in ids:
    if ($seq->id =~ /\s/) {
#      warn "White space in ID: \"", $seq->id,"\" skipping entry...\n";
      warn "White space in ID: \"", $seq->id, "\" (accession: ", $seq->accession_number(), ") skipping entry...\n";
      next;
    }

    # Add gff features to the Seq obj:
    if ($gffin) {
      add_gff_features($seq);
    }

    if ($revcompl && $allplus) {
      die "Options --revcompl and --allplus are incompatible.\n";
    } elsif ($revcompl) {
      $seq = revcomplseq($seq)
    }

    # See if we need to reverse complement the Seq obj:
    if ($allplus) {
      my $plus = 0;
      my $minus = 0;
      my @features = $seq->all_SeqFeatures();
      foreach my $f (@features) {
        if ($f->primary_tag() eq $allplus) {
          if (ref($f->location()) eq 'Bio::Location::Split') {
            my @sl = $f->location->sub_Location();
            if ($sl[0]->strand() eq '-1') {
              $minus = 1;
            } else {
              $plus = 1;
            }
          } else {
            if ($f->strand() eq '-1') {
              $minus = 1;
            } else {
              $plus = 1;
            }
          }
        }
      }
      if ($minus && !$plus) {
        $seq = revcomplseq($seq);
      }
    }

    my $string = $seq->seq();

    my @letters = split //, $string;
    my @labels;
    my $id = $seq->accession_number();
    my $desc = $seq->desc();
    my $header = "$id";
    $header .= " $desc" if $desc;
    # Get the features:
    my @allfeatures = $seq->all_SeqFeatures();
    my @features = ();

    # Make an array of all the features (each in a hash):
    for my $f (@allfeatures) {
      if ($f->primary_tag() =~ /$regex/i ) {

        my $fhash = {};
        if (ref($f->location()) eq 'Bio::Location::Split') {
          # Get the array of Bio::Location::Simple objs.:
          my @sl = $f->location->sub_Location();
          my $splitlocation = [];
          $$fhash{primary_tag} = $f->primary_tag();
          foreach my $sl (@sl) {
            push @$splitlocation, {start => $sl->start(),
                                   end => $sl->end(),
                                   strand => $sl->strand() }
          }
          $$fhash{splitlocation} = $splitlocation;
        } else {
          $fhash = { primary_tag => $f->primary_tag(),
                     start => $f->start(),
                     end => $f->end(),
                     strand => $f->strand() };
        }
        push @features, $fhash;
      }
    }

    # Sort the feature list so features on the minus strand is first:
    @features = sort {
      my $astrand;
      my $bstrand;
      if ($a->{splitlocation}) {
        $astrand = ${$a->{splitlocation}}[0]->{strand};
      } else {
        $astrand = $a->{strand};
      }
      if ($b->{splitlocation}) {
        $bstrand = ${$b->{splitlocation}}[0]->{strand};
      } else {
        $bstrand = $b->{strand};
      }
      $astrand <=> $bstrand;
    } @features;

    # Find out which feature the sequence pos. is contained in:
  letter: for my $i (1 .. @letters) {
      my $label = 0;
      my $shadow = 0;

      # If there are any features that are allowed to shadow from the
      # other strand, then lets look for them first:
      if (@shadowfeatures) {
        foreach my $feat (@shadowfeatures) {
          # Is there a feature corresponding to the label and if so does it
          # cover the letter:
          foreach my $f (@features) {
            if ($f->{splitlocation}) {
              foreach my $l (@{$$f{splitlocation}}) {
                if ($i >= $l->{start} && $i <= $l->{end}) {
                  if ($l->{strand} eq '-1') {
                    $label = $labels{shadow};
                    push @labels, $label;
                    next letter;
                  }
                }
              }
            } elsif ($i >= $f->{start} && $i <= $f->{end}) {
              if ($f->{strand} eq '-1') {
                $label = $labels{shadow};
                push @labels, $label;
                next letter;
              }
            }
          }
        }
      }

      # Run through the features from the labelkey to see if they match
      # a the base position:
      foreach my $feat (@inputfeatures) {

        # Is there a feature corresponding to the label and if so does it
        # cover the letter:
        foreach my $f (@features) {

          # See if sequence position is contained in a feature:
          if ($feat eq $f->{primary_tag}) {

            if ($f->{splitlocation}) {
              foreach my $l (@{$$f{splitlocation}}) {
                if ($i >= $l->{start} && $i <= $l->{end}) {
                  if ($l->{strand} eq '1') {
                    $label = $labels{$f->{primary_tag}};
                    push @labels, $label;
                    next letter;
                  }
                }
              }
            } elsif ($i >= $f->{start} && $i <= $f->{end}) {
              if ($f->{strand} eq '1') {
                $label = $labels{$f->{primary_tag}};
                push @labels, $label;
                next letter;
              }
            }
          }
        }
      }
      if (!$label) {
        push @labels, "$labels{default}";
      }
    }

    @letters == @labels
      or die "Number of labels does not corresond to the number of bases/aminoacids\n";

#    my $lfa = LFasta->new(-header => ">$header",
    my $lfa = LFasta->new(-id => $seq->id,
                          -seq => join('', @letters),
                          -labels => join('', @labels));
    print $out $lfa;
  }
}

# }}}

exit 1;

# {{{ GFF functions

# # =====  gff2_to_gff3.pl =====
# my( $gff2File ) = @ARGV;
# my $gffio = Bio::Tools::GFF->new(-file=>"$gff2File", -gff_version=>2);
# while( my $feature = $gffio->next_feature() ) {
#     my $gff3string = $gffio->_gff3_string( $feature );
#     print "$gff3string\n";
# }
# $gffio->close();
# 
# # =====  gff3_to_gff2.pl =====
# my( $gff3File ) = @ARGV;
# my $gffio = Bio::Tools::GFF->new(-file=>"$gff3File", -gff_version=>3);
# while( my $feature = $gffio->next_feature() ) {
#     my $gff2string = $gffio->_gff2_string( $feature );
#     print "$gff2string\n";
# }
# $gffio->close();

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
#   for my $f (@features) {
#     my $id = $seq->id;
#     my $gff = make_gff($f, $id, $seq);
#     push @gfflines, "$gff\n";
#     # If 'mRNA' of 'CDS' features contain sublocations, make GFF
#     # strings for exons and introns:
#     if (ref($f->location()) eq 'Bio::Location::Split'
#         and $f->primary_tag() =~ /mRNA|CDS/i) {
#       # Get the array of Bio::Location::Simple objs.:
#       my @sl = $f->location->sub_Location();
#       for (my $j = 0; $j < @sl; $j++) {
#         my $subid = $id . "_e" . eval{$j + 1};
#         my $subgff =  makesubgff('exon',
#                                  $sl[$j]->start(),
#                                  $sl[$j]->end(),
#                                  $id, $subid,
#                                  $f);
#         push @gfflines, "$subgff\n";
#         unless ($j == @sl - 1) {
#           my $subid = $id . "_i" . eval{$j + 1};
#           $subgff =  makesubgff('intron',
#                                 $sl[$j]->end() + 1,
#                                 $sl[$j+1]->start() - 1,
#                                 $id,
#                                 $subid,
#                                 $f);
#           push @gfflines, "$subgff\n";
#         }
#       }
#     }
#   }

  return \@gfflines;
}

sub add_gff_features {
  my $seq = shift;
#   my $gffio = Bio::Tools::GFF->new(-fh => $gffin,
#                                    -gff_version => $gffversion);
#   while(my $feature = $gffio->next_feature()) {
#     $seq->add_SeqFeature($feature);
#   }
#   $gffio->close();

  for my $gff (@{$gffhash{$seq->id}}) {
    my $feature = new Bio::SeqFeature::Generic( -gff_string => $gff );
    $seq->add_SeqFeature($feature);
  }
}

sub make_gff {
  my ($feature, $id, $Seq) = @_;
  my $type = 'Sequence';
  my $gff = $feature->gff_string();
  $gff =~ /^(\S+)(\t\S+\t\S+\t)(\S+)\t(\S+)(\t\S+\t\S+\t\S+\t)(.*)$/;
  $gff = $Seq->accession() . $2 . $feature->start() . "\t" . $feature->end()
    . $5 . "$type:$id 1 " . eval{$feature->end() - $feature->start() + 1} . " ; " . $6;
  return $gff;
}

sub makesubgff2 {
  my ($name, $start, $end, $id, $subid, $feature) = @_;
  my $type = 'Sequence';
  my $gff = sprintf "$id\tEMBL/GenBank/SwissProt\t$name\t$start\t$end\t.\t%s\t.\t$type:$subid 1 %d",
    eval{ $feature->strand() == 1 ? '+' : '-' }, eval{$end - $start + 1};
  return $gff;
}

sub makesubgff3 {
  my ($name, $start, $end, $id, $strand) = @_;
  my $gff = sprintf "$id\tEMBL/GenBank/SwissProt\t$name\t$start\t$end\t.\t%s\t.\tParent=$id",
    $strand == 1 ? '+' : '-', $end - $start + 1;
  return $gff;
}

sub printgff {
  my @entry = @{$_[0]};
  my $i=0;
  for ($i=0; $i<8; ++$i) {
    $entry[$i] = "." if (!defined($entry[$i]));
    print $gffout "$entry[$i]";
    print $gffout "\t" if ($i<7);
  }
  print $gffout "\t$entry[8]" if (defined($entry[8]));
  print $gffout "\t$entry[9]" if (defined($entry[9]));
  print $gffout "\n";
}

# }}}

# {{{ Misc functions

sub handle_exception {
  my $exepts_str = shift;
  if ($@=~ /MSG:\s*(.*)/) {
    die "$1\n";
  } else {
    die $exepts_str;
  }
}

# sub break_into_segments {
#   my @list = @_;
#   my $sublist = ();
#   my @lol;
#   for my $entry (@list) {
#     push @$sublist, $entry;
#     if (@$sublist == 70) {
#       push @lol, $sublist;
#       $sublist = ();
#     }
#   }
#   push @lol, $sublist if defined($sublist);
#   return @lol;
# }

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

sub revcomplseq {

  my $seq = shift;

  my $string = $seq->seq();
  my @compl;
  # Complement it:
  $string =~ tr/AGCTNagctn/TCGANtcgan/;
  # Reverse it:
  my @string = split //, $string;
  while (@string) {
    push @compl, (pop @string);
  }
  $seq->seq(join "", @compl);

  # Reverse compelment the features:
  my @f = $seq->all_SeqFeatures();
  for(my $i=0; $i<@f; $i++) {
      if (ref($f[$i]->location()) eq 'Bio::Location::Split') {
        # Get the array of Bio::Location::Simple objs.:
        my @sl = $f[$i]->location->sub_Location();
        for (my $i=0; $i<@sl; $i++) {
          my $newstart = $seq->length() - $sl[$i]->end() + 1;
          my $newend = $seq->length() - $sl[$i]->start() + 1;
          $sl[$i]->start($newstart);
          $sl[$i]->end($newend);
          $sl[$i]->strand($sl[$i]->strand() * -1);
        }
      } else {
          my $newstart = $seq->length() - $f[$i]->end() + 1;
          my $newend = $seq->length() - $f[$i]->start() + 1;
          $f[$i]->start($newstart);
          $f[$i]->end($newend);
          $f[$i]->strand($f[$i]->strand() * -1);
      }
    }
  return $seq;
}

# }}}


#######  POD:  #############################################


=head1 SYNOPSIS:

 reformat.pl [OPTIONS] [input file [output file]]

=head1 DESCRIPTION:

This script does reformatting between sequence formats. It handles
GenBank, EMBL, Fasta and all the other formats supported by
bioperl. In addition it formats to labeled fasta (lfa) which is the a
handy extention of the fasta format developed by Anders Krogh for use
in HMM training. The labeling is generated from the sequence features
in a manner directed by the --labelkey option. The information surplus
or deficit when formatting between rich formats like EMBL and Fasta
can be handled by using the gff option. This specifies a gff file that
is read from or written to depending on the which way the formatting
goes.

=head1 OPTIONS:

=over 4

=item --informat

Specifies input format. If format is not specified
the script takes pains to gues it.

=item --outformat

Specifies output format. If format is not specified
the script takes pains to gues it.

=item --labelkey

Associates features with a labeling key based of the
primary tag in the feature annotation. Eg. 'exon:C
intron:I defult:N'. The default key defaults to
'-'. Note that in the where more than one of the
specified features cover a base, the first one is always
chosen. This way nesting of features can be controled to
some extent. The special 'shadow' tag can be given as
eg. shadow:S and controls which features on the minus
strand that may produce a shadow label on the plus
strand. Only the features listed after the shadow tag
will produce shadowing. Note that the shadow tag is only
used when formatting to Labeled Fasta. If the option is
not given, the labelkey defaults to CDS:C exon:E
intron:I intron:0 intron:1 intron:2 5\'UTR:5 3\'UTR:3
poly-A:A

=item --useaccession

For use with reformating from a 'richseq' to
Fasta. Makes onlythe accesion number from the 'richseq'
appear as the id in the generated Fasta entry.

=item --gff <filename>

Specifies a GFF file to read from or write to depending
on whether you are reformating from Fasta to a format
holding sequence features or the other way around. If
you want to use standard input of standard output, you
can give '&STDIN' or '&STDOUT' as argument.

=item --gffversion <int>

Version of GFF to use. Default is 3. Can only be 2 or 3.

=item --labelgroups "<groupname>:<labelstring> ..."

Specifies grouping by parent field. Same notation as for
labelkey (see example)

=item --labelprefix <regex>

Regular expression for the lines in each Labeled Fasta
entry to process.

=item --help

Prints this help.

=item --revcompl

Reverse complments the entry and all the associated
feature information.

=item --allplus <feature>

Reverse complments the entry and all the associated
feature information if a <feature> is on the minus
strand. Handy in making HMM training sets where the CDSs
have to be on the forward strand. In case of CDSs on
both strands it no reverse complementation is done.

=item --trainingset

Convenience option. Same as "-outformat LFasta
-allplus CDS -labelkey 'CDS:C intron:I default:x"

=item --help

Produces this help.

=back

=head1 EXAMPLES:

 # Standard reformatting:

 reformat.pl file.gb file.embl

 reformat.pl --informat fasta --outformat genbank file1 file2

 # this is equivalent to:

 reformat.pl -in fa -out gb file1 file2

 cat file.gb | reformat.pl -in gb -out embl > file.embl

 # GFF stuff:
 # This will write GFF lines to file.gff

 reformat.pl -gff file.gff file.embl file.fa

 # This will read GFF lines from file.gff

 reformat.pl -gff file.gff file.fa file.embl

 # Labeled Fasta stuff:

 reformat.pl --labelkey "intron:I 5'UTR:5 shadow:S CDS:C" file.gb file.lfa

 reformat.pl -labelkey "exon:E" -labelgr "transcript:EI" file.lfa file.gb

 reformat.pl file.lfa file.embl

=head1 DEPENDENCIES:

The classes: LFasta LFastaIO SeqFunctions. These are not on CPAN but
if you send me and email (kasper at binf.ku.dk) I will be more than happy
the send them.

=head1 AUTHOR:

Kasper Munch

=head1 COPYRIGHT:

This program is free software. You may copy and redistribute it under
the same terms as Perl itself.


=cut
