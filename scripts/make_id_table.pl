#!/usr/bin/perl

@lines='';
# @out='';

#read line of TE file from standard input
while ($line = <>) {
	push (@lines, $line);
}

$length = @lines;

for ($i=0; $i<$length; $i++) {
    if ($lines[$i] =~ /^ID/) {
        $out = $lines[$i];
        # print "$out\n";
        @out = split(' ', $out);
        $embl_id = @out[1];
        # print "$out\n"
    }
	if ($lines[$i] =~ /^DR/) {
		$out = $lines[$i];
        # print "$out\n";
        @out = split('; ', $out);
        $fb_id = @out[1];
        # print "$out\n"
	}
    if ($lines[$i] =~ /^FT.*source/) {
        $out = $lines[$i];
        # print "$out\n";
        @out = split(' ', $out);
        $source_id = @out[2];
        $source_id =~ s/:.*//g;
        $source_id =~ s/.*\(//g;
        # print "$out\n"
        @out = ($embl_id, $fb_id, $source_id);
        print join("\t", @out), "\n";
    }
}