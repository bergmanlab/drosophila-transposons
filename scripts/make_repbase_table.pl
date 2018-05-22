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
Description:	this program is used to generate look up table for embl id, and repbase annotation
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

my @lines=();
my @embl_id=();
my @kwtmp=();
my @kwout=();

#read line of TE file from standard input
while (my $line = <IN>) {
    chomp $line;
	push (@lines, $line);
}

my $length = @lines;
my $idx = -1;
my $kdx = 0;


for (my $i=0; $i<$length; $i++) {
    if ($lines[$i] =~ /^ID/) {
        $idx = $idx + 1;
        my $out = $lines[$i];
        my @out = split(' ', $out);
        $embl_id[$idx] = $out[1];
        push (@kwout, "");
        if ($kdx > 0) {
            my $kwstring = join ( '', @kwtmp );
            $kwstring =~ s/KW\s+//g;
            $kwout[$idx-1] = $kwstring;
            $kdx = 0;
            @kwtmp=();
        }
    }
    if ($lines[$i] =~ /^KW/) {
        $kdx = $kdx + 1;
        $kwtmp[$kdx] = $lines[$i];
    }
}

while (@embl_id || @kwout ) {
   print OUT shift(@embl_id) . "," . shift(@kwout) . "\n";
}

close IN;
close OUT;