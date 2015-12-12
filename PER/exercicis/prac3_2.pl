#!/usr/bin/perl
use strict;
use warnings;

my @matrix=([1,2,3],[5,7,12],[10,12,13]);


my $nrows=scalar @matrix;
my $ncols=scalar @{$matrix[0]};
my @tmatrix;

for (my $i = 0 ; $i < $nrows ; $i++){
	for (my $j = 0 ; $j < $ncols ; $j++){
		$tmatrix[$i][$j]=$matrix[$j][$i];
	}
}

print "The transposed matrix is:\n";
for (my $ii = 0 ; $ii < $nrows ; $ii++){
	for (my $jj = 0; $jj < $ncols ; $jj++){
		print $tmatrix[$ii][$jj] . " ";
	}
	print "\n";
}
print "And its diagonal vector:\n";

for (my $iii=0;$iii<$nrows;$iii++){
	print $tmatrix[$iii][$iii] . " ";
}
print "\n";
