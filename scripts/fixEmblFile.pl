#! /usr/bin/perl -w

# usage
if ($#ARGV != 0) {
        die "Usage: fixEmblFile.pl transposon_sequence_set.embl.txt\n";
}

my $feature = '';
my $id = '';
my $coords = '';
my $nextFeature = '';
my $nextId = '';
my $nextCoords = '';

#read line of TE file from standard input
while ($line = <>) {

	#if line has SO feature, get relevant info
	if ($line =~ /SO_feature\s+(\S+)\s\;\s(SO:\S+):(\S+)/) {
		$feature = $1;
		$id = $2;
		$coords = $3;

		# convert the position of start codons from relative to absolute for complete orfs on the + strand	
		# this conversions requires reorderStartCodons.pl to be run first to make sure that CDS comes after start_codon
		
		if ($feature eq 'start_codon') {
			$nextLine = <>;
			if ($nextLine =~ /SO_feature\s+(\S+)\s\;\s(\S+):(\S+)/) {
			
			#FT   SO_feature      CDS ; SO:0000316:join(155..447,512..1179,1242..1967,2159..2733)
			#FT   SO_feature      CDS ; SO:0000316:394..1440

				$nextFeature = $1;
				$nextId = $2;
				$nextCoords = $3;
			}
			
			if ($nextCoords =~ /</ || $nextCoords =~ />/ || $nextCoords =~ /complement/) {
				#print "$line";
				#print "feature is $feature\tcoords are $coords\tnextFeature is $nextFeature\tnextCoords are $nextCoords\n";
				#print "incomplete ORF\n\n";
				print "FT   $nextFeature     $nextCoords\n";
				print "FT                   /Ontology_term=\"$nextId\"\n";
			}
			
			elsif ($nextCoords =~ /(\d+)..(\d+)/) {
				
				print "FT   $feature     $1..".($1+2)."\n";
				print "FT                   /Ontology_term=\"$id\"\n";
				print "FT   $nextFeature     $nextCoords\n";
				print "FT                   /Ontology_term=\"$nextId\"\n";

			}
		}

		else {
			print "FT   $feature     $coords\n";
			print "FT                   /Ontology_term=\"$id\"\n";
		}
	}
		
	#if not a SO feature line, do nothing
	else {
		print "$line";
	}

}