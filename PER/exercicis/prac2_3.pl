#!/usr/bin/perl

use strict;
use warnings;

# declaring some variables
my ($dna_seq,$subseq);

# initializing variables
$dna_seq  = "ATGCATTGGGGAACCCTGTGCGGATTCTTGTGGCTTTGGCCCTATCTTTTCTATGTCCAAGCTG".
            "TGCCCATCCAAAAAGTCCAAGATGACACCAAAACCCTCATCAAGACAATTGTCACCAGGATCAA";

# Looping throught the sequence
my $seqlen = length($dna_seq);
my $sub_string = "TT";
my @seq_arr=split(//,$dna_seq);
$subseq=0;
my @index_array;

for(my $i=0;$i<($seqlen-1);$i++){
    if ($seq_arr[$i].$seq_arr[$i+1] eq $sub_string){ 
        $subseq++;
        push @index_array, $i+1;
    } 
}

my $index_string = join ',',@index_array; 
# Printing results
print STDOUT "The list of the positions of $sub_string in the sequence = $index_string\n";
