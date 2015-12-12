#!/usr/bin/perl
use strict;
use warnings;

my @array;
my $num;
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

my $nelem=scalar @array - 1;
my @final_array=($array[0]);
for (my $i = 0 ; $i < $nelem ; $i++){
    push @final_array,($array[$i]+$array[$i+1])/2;
    push @final_array,$array[$i+1];
}
my $print_stg=join(" ",@final_array);
print $print_stg . "\n";
