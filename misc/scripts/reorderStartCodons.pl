#! /usr/bin/perl -w

# this script re-orders the location of SO_features with type 
# "start_codon" to be positioned before features with type "CDS".
# Note: not all CDSs have an associated start_codon entry

@lines='';
@reordered='';

#read line of TE file from standard input
while ($line = <>) {
	push (@lines, $line);
}

$length = @lines;

for ($i=0; $i<$length; $i++) {
	if ($lines[$i] =~ /start_codon/) {
		$reordered[$i] = $lines[$i-1];
		$reordered[$i-1] = $lines[$i];
	}
	else {
		$reordered[$i] = $lines[$i];
	}
}

print @reordered;
