#!/usr/bin/perl

use strict;
use warnings;

for (my $i = 10 ; $i >= 0 ; $i = $i - 1){

	print STDERR $i; 
	print STDERR " ";
	print STDERR "\r";
	sleep 10;

}
#my $i=100;
#while ($i > 0){
#	print $i . "\r";
#	sleep 10;
#	$i=$i-1;
#}
