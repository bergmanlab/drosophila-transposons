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

	    #find length of SO feature string and add padding to make columns 6-20 in EMBL file
	    # this is no longer necessary since padding required for long SO strings exceed EMBL format
	    # embl converter doesn't require fixed width or embl tags
	    
#		my $feature_string_length = length $feature;
#		my $padding = '';
#		for (my $i=$feature_string_length; $i<100; $i++) {
#			$padding .= " ";
#		}			

		#convert position of start codons for complete orfs on the + strand	
		if ($feature eq 'start_codon') {
			$nextLine = <>;
			if ($nextLine =~ /SO_feature\s+(\S+)\s\;\s(\S+):(\S+)/) {
			
			#FT   SO_feature      CDS ; SO:0000316:join(155..447,512..1179,1242..1967,2159..2733)
			#FT   SO_feature      CDS ; SO:0000316:394..1440


				$nextFeature = $1;
				$nextId = $2;
				$nextCoords = $3;
			}
			
#			$next_feature_string_length = length $nextFeature;
#			$next_padding = '';
			
#			for (my $i=$next_feature_string_length; $i<100; $i++) {
#				$next_padding .= " ";
#			}
			
			if ($nextCoords =~ /</ || $nextCoords =~ />/ || $nextCoords =~ /complement/) {
				#print "$line";
				#print "feature is $feature\tcoords are $coords\tnextFeature is $nextFeature\tnextCoords are $nextCoords\n";
				#print "incomplete ORF\n\n";
				print "FT   $nextFeature     $nextCoords\n";
				print "FT                   /db_xref=\"$nextId\"\n";
			}
			
			elsif ($nextCoords =~ /(\d+)..(\d+)/) {
				
				#print "$line";
				#print "feature is $feature\tcoords are $coords\tnextFeature is $nextFeature\tnextCoords are $nextCoords\n";
				#print "start codon $1 to $2\n\n";
				print "FT   $feature     $1..".($1+2)."\n";
				print "FT                   /db_xref=\"$id\"\n";
				print "FT   $nextFeature     $nextCoords\n";
				print "FT                   /db_xref=\"$nextId\"\n";

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
