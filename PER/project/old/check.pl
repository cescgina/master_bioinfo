#!/usr/bin/perl
use strict;
use warnings;

my %dist;
my @scores;
#my $file="pax6_output.txt";
#my $file="output3.txt";
my $file="pax-6_output100S_10000M.txt";
open(my $fh,"<$file")
    or die $!;
#while(<$fh>){
#    if (m/^PO/){
#        last;
#    }
#}
<$fh>;
while (<$fh>){
    if(m/[A-Z]+\s+(\d+)$/){
        if (exists($dist{$1})){
            $dist{$1}++;
        }
        else{
            $dist{$1}=1;
            push @scores,$1;
        }
    }
}
close $fh;
#my $out="output_check3.txt";
my $out="output_check_100S.txt";
open(my $fh2,"> $out")
    or die $!;
foreach my $score (@scores){
    print $fh2 "$score\t$dist{$score}\n";
}
close $fh2;
