#!/usr/bin/perl
use strict;
use warnings;
use Functions;

my $filename=shift @ARGV;
my @PWM=Functions::readTRANSFAC($filename);
my $n=scalar @PWM;
my $m=scalar @{$PWM[0]};
my $npos_seq=Functions::numbersequences(\@PWM);
my @orign_order=("A","C","G","T");
my $M=1000; #Limit of generated sequences, fixed arbitrarely
my $nseq=( ($npos_seq < $M) ? $npos_seq : $M); #$nseq is the limit of sequences generated
my @secPWM=Functions::genmat(\@PWM,\@orign_order); #generate a matrix with the columns ordered
my @PWM2;
my @nuclorder;

#split the matrix with the ordered columns between the PWM and the nucleotides position matrix
for (my $i=0;$i<$n;$i++){
    for (my $j=0;$j<$m;$j++){
        ($PWM2[$i][$j],$nuclorder[$i][$j])=split(/\./,$secPWM[$i][$j]);
    }
}
my @order_rows=Functions::sort_rows(\@PWM2); #Get the optimal ordering of the rows 
@secPWM=Functions::swap_rows(\@PWM2,\@order_rows); #Reuse names of arrays for space optimization
my @secnuclorder=Functions::swap_rows(\@nuclorder,\@order_rows);
my @PWMscores=Functions::genscores(\@secPWM); #Generate matrix of scores with relative frequences using the optimal ordering

#Block of code to print matrices (temporary)
#for (my $ii=0;$ii<$n;$ii++){
#    for (my $jj=0;$jj<$m;$jj++){
#        #print $secPWM[$ii][$jj] . "\t";
#        print $PWMscores[$ii][$jj] . "\t";
#    }
#    print "\n";
#}

my $genseq=0; #Number of sequences generated from the PWM
my $seqref={};
my $score=0;
my $row=0;
my $col=0;
my $lastcolindex=[(0) x $n];
my @array_seqs=[1,''];
print "Sequence\tScore\n";
#while ($genseq < $nseq){
#my $iii=0;
#while ($iii<31){
    Functions::genseq(\@secPWM,\@PWMscores,\@secnuclorder,\@order_rows,$seqref,\@array_seqs,$row,\$nseq,\$genseq,$lastcolindex);
#    print %{$seqref};
#    print "\n";
#Functions::genseq(\@secPWM,\@PWMscores,\@secnuclorder,\@order_rows,$seqref,$row,$score,\$M,\$genseq);
#    $iii++;
#}
#foreach my $array (@array_seqs){
#    print "${$array}[1]\t${$array}[0]\n";
#}

