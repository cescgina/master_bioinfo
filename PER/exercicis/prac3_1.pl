#!/usr/bin/perl
use strict;
use warnings;
my @array;
my $num;
my $median=0;

while(1){
    my $digit=1;
    print "Please introduce as many numbers as you wish separated by an space:\n";
    $num=<>;
    chomp($num);
    @array=split(/ /,$num);

    if (@array ){
        foreach my $element (@array){
            if ($element =~ m/[^\d+]/){
                $digit=0;
            }    
        }
        if ($digit){
            last;
        }
    }
}


@array = sort { $a <=> $b } @array;
my $n_elem= $#array + 1;


if ($n_elem % 2 == 0){
	$median=(@array[int($n_elem/2)-1]+@array[int($n_elem/2)])/2;
}
else{
	$median=@array[int($n_elem/2)];
}
print "The median of the numbers is: $median\n";
