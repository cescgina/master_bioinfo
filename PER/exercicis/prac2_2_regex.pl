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

my $half_sub = substr($sub_string,0,1);
my @seq_array = $dna_seq =~ /$sub_string/g;
$dna_seq =~ s/$sub_string/0/g;
my @seq_array2 = $dna_seq =~ /(0$half_sub|00)/g;
$subseq = scalar @seq_array + scalar @seq_array2;
my $freq = $subseq/$seqlen;
my $freq_str= sprintf("%.2f",$freq);
 
# Printing results
print "The total number of ocurrences of $sub_string in the sequence = $subseq\n";
print "The frequency of $sub_string in the sequence = $freq_str\n";
