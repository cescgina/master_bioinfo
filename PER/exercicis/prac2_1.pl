#!/usr/bin/perl
use strict;
use warnings;

my $line;
while (1){
    print "Please, insert a number: \n";
    $line=<STDIN>;
    chomp($line);
    if ($line < 0){
        warn "Factorial is only defined for positive integers, please insert a positive integer!";
    }
    else{
        last;
    }
}
my $fact=factorial($line);
print "$line! = $fact\n";

sub factorial {
	my $n=$_[0];
	my $fact;
	if ($n < 2) {
		$fact = 1;
	}
	else{
		$fact = $n*factorial($n-1);
	}
	return $fact;
}
