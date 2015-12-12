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

for(my $i=0;$i<($seqlen-1);$i++){
    ($seq_arr[$i].$seq_arr[$i+1] eq $sub_string) && ($subseq++);
}
my $freq = $subseq/$seqlen;
my $freq_str= sprintf("%.2f",$freq);
 
# Printing results
print "The total number of ocurrences of $sub_string in the sequence = $subseq\n";
print "The frequency of $sub_string in the sequence = $freq_str\n";
