#!/usr/bin/perl
use strict;
use warnings;
use Functions;

my $filename=shift @ARGV or die "Usage $0 FILENAME [-options]";

my $help=<<'HELP';
Usage: sequence_generator.pl TRANSFAC_FILE [OPTIONS]
Produce the topmost scoring sequences from a position weight matrix.

-n    number of sequences to be generated (by default 10000)
-o    output file (by default prints to STDOUT)
-s    sensitivity of the heuristic algorithm (by default 10)(see report for details)
-S    number of sequences to be generated in the heuristic algorithm (by default 10)
-a    flag to generate all possible sequences (WARNING! this number may be too big and fill out the memory)
HELP
if ($filename eq "-h" or $filename eq "--help"){
    print $help;
    exit;

}
my ($PWMref,$name)=Functions::readTRANSFAC($filename);
my @PWM=@{$PWMref};
my $n=scalar @PWM;
my $m=scalar @{$PWM[0]};
my $npos_seq=Functions::numbersequences(\@PWM);
my @orign_order=("A","C","G","T");
my $M=10000; #Limit of generated sequences, fixed arbitrarely, default value is 10000, can be specified with the -n option
my $alpha=10; #Size of the heuristic algorithm next steps, as fraction of M, default value is 1, can be specified with the -S option
my $sens=10; #Sensitivity of the heuristics algorithm nest step, i.e. the range of values that will trigger next iteration, default value is 10, can be specified with the -s option
my $fileout=undef;

#Arguments parsing block
while (@ARGV){
    my $option=shift @ARGV;
    if ($option =~ m/-*(\w+)/){
        if ($1 eq "h" or $1 eq "help"){
            print $help;
            exit;
        }
        if ($1 eq "n"){
            $M=shift @ARGV;
        }
        elsif ($1 eq "S"){
            $alpha=shift @ARGV;
        }
        elsif ($1 eq "o"){
            $fileout=$name;
        }
        elsif ($1 eq "s"){
            $sens=shift @ARGV;
        }
        elsif ($1 eq "a"){
            $M=$npos_seq;
        }
    }

}

if ($fileout){
    if ($npos_seq < $M){
        $fileout .= "_output.txt";
    }
    else{
        $fileout .= ("_output".$alpha."S_".$M."M.txt");
    }
}
my $S=$alpha*$M;
my $nseq=( ($npos_seq <= $M) ? $npos_seq : 0); #$nseq is the limit of sequences generated, only different than zero if the total number of possibilities is smaller than the number of sequences asked
my $heuristiciter=( ($npos_seq < $M) and ($S > 0) ? 1 : 0); #$heuristiciter is a contol variable to set the multiple iterations of size S(see report for details)

####Sorting of the matrix
my @secPWM=Functions::genmat(\@PWM,\@orign_order); #generate a matrix with the columns ordered
my @PWM2;
my @nuclorder;
#split the matrix with the ordered columns between the PWM and the nucleotides position matrix
for (my $i=0;$i<$n;$i++){
    for (my $j=0;$j<$m;$j++){
        ($PWM2[$i][$j],$nuclorder[$i][$j])=split(/\./,$secPWM[$i][$j]);
    }
}
my @PWM3;
for (my $i=0;$i<$n;$i++){
    ###Create the matrix encoding the score change
    $PWM3[$i][0]=$PWM2[$i][0]-$PWM2[$i][1];
    $PWM3[$i][1]=$PWM2[$i][1];
    $PWM3[$i][2]=$PWM2[$i][2];
    $PWM3[$i][3]=$PWM2[$i][3];
}

my @order_rows=Functions::sort_rows(\@PWM3); #Get the optimal ordering of the rows 
@PWM2=Functions::swap_rows(\@PWM2,\@order_rows); #Reuse names of arrays for space optimization
@nuclorder=Functions::swap_rows(\@nuclorder,\@order_rows);

###Generating sequences
my $genseq=0; #Number of sequences generated from the PWM
my $row=0;
my $lastcolindex=[(0) x $n];
my @array_seqs=[];
my $lastscore=0;
my $niter=0;
Functions::genseq(\@PWM2,\@nuclorder,\@order_rows,\@array_seqs,$row,\$M,\$nseq,\$genseq,$lastcolindex,\$heuristiciter,\$S,\$lastscore,\$niter,\$fileout,\$sens);
Functions::sort_array(\@array_seqs,\$lastscore,\$nseq);
Functions::print_sequences(\@array_seqs,$nseq,$fileout);
