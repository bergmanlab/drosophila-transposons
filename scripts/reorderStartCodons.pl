#! /usr/bin/perl -w

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
