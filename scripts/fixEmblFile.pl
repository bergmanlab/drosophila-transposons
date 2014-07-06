#! /usr/bin/perl -w

# usage
if ($#ARGV != 0) {
        die "Usage: TE_to_EMBL.pl transposon_sequence_set.v.9.42.txt\n";
}

#lookup hash table of SO terms converted to EMBL feature keys
my %SO_to_EMBL = qw(CDS CDS dinucleotide_repeat_microsatellite_feature repeat_unit direct_repeat repeat_unit five_prime_LTR repeat_unit five_prime_UTR 5'UTR intron intron inverted_repeat repeat_unit long_terminal_repeat repeat_unit polyA_sequence misc_RNA polyA_signal_sequence misc_RNA polyA_site polyA_site primer_binding_site primer_bind pseudogene misc_RNA region misc_structure RR_tract repeat_unit start_codon misc_RNA TATA_box TATA_signal terminal_inverted_repeat repeat_unit tetranucleotide_repeat_microsatellite_feature repeat_unit three_prime_LTR repeat_unit three_prime_UTR 3'UTR transcription_start_site misc_signal);

my $feature = '';
my $id = '';
my $coords = '';
my $nextFeature = '';
my $nextId = '';
my $nextCoords = '';

#read line of TE file from standard input
while ($line = <>) {

	#if line has SO feature, get relevant info
	if ($line =~ /SO_feature\s+(\S+)\s\;\s(\S+):(\S+)/) {
		$feature = $1;
		$id = $2;
		$coords = $3;

	    #find length of SO feature string and add padding to make columns 6-20 in EMBL file
		my $feature_string_length = length $feature;
		my $padding = '';
		for (my $i=$feature_string_length; $i<16; $i++) {
			$padding .= " ";
		}			

		#convert position of start codons for complete orfs on the + strand	
		if ($feature eq 'start_codon') {
			$nextLine = <>;
			if ($nextLine =~ /SO_feature\s+(\S+)\s\;\s(\S+):(\S+)/) {
				$nextFeature = $1;
				$nextId = $2;
				$nextCoords = $3;
			}
			
			$next_feature_string_length = length $nextFeature;
			$next_padding = '';
			
			for (my $i=$next_feature_string_length; $i<16; $i++) {
				$next_padding .= " ";
			}
			
			if ($nextCoords =~ /</ || $nextCoords =~ />/ || $nextCoords =~ /complement/) {
				#print "$line";
				#print "feature is $feature\tcoords are $coords\tnextFeature is $nextFeature\tnextCoords are $nextCoords\n";
				#print "incomplete ORF\n\n";
				print "FT   $nextFeature$next_padding$nextCoords\n";
				print "FT                   /db_xref=\"$nextId\"\n";
			}
			
			elsif ($nextCoords =~ /(\d+)..(\d+)/) {
				
				#print "$line";
				#print "feature is $feature\tcoords are $coords\tnextFeature is $nextFeature\tnextCoords are $nextCoords\n";
				#print "start codon $1 to $2\n\n";
				print "FT   $feature$padding$1..".($1+2)."\n";
				print "FT                   /db_xref=\"$id\"\n";
				print "FT   $nextFeature$next_padding$nextCoords\n";
				print "FT                   /db_xref=\"$nextId\"\n";

			}
		}

		#map SO feature back to EMBL feature keys and make new FT line with dbxref to SO
		else {
			#print "FT   $SO_to_EMBL{$feature}$padding$coords\n";
			print "FT   $feature$padding$coords\n";
			#print "FT                   /db_xref=\"$id; $feature\"\n";
			print "FT                   /Ontology_term=\"$id\"\n";
		}
	}
		
	#if not a SO feature line, do nothing
	else {
		print "$line";
	}

}
