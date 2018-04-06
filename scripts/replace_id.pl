#!/usr/bin/perl

use strict; use warnings;

my %hash;

open( my $TABLE, '<', "../current/te_id_table.tsv" );
#read line of TE file from standard input
while (my $line = <$TABLE>) {
	# chomp $_;
    my ($embl_id, $fb_id, $source_id) = split(' ', $line);
    $hash{$embl_id} = $fb_id;
}
close( $TABLE );

# print "Key: $_ and Value: $hash{$_}\n" foreach (keys%hash);

open( my $EMBL_DATA, '<', "../current/transposon_sequence_set.embl.txt" );
open( my $OUTPUT, '>', "../current/transposon_sequence_set.embl.id_replaced.txt" );

while ( <$EMBL_DATA> ) {
  foreach my $key ( sort keys %hash ) {
     s/\b$key\b/$hash{$key}/g;
  }
  print $OUTPUT $_; 
}

close( $EMBL_DATA );
close( $OUTPUT );