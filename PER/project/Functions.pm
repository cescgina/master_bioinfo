package Functions;
use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);
use Exporter;
$VERSION=1.00;
@ISA = qw(Exporter);
@EXPORT = qw();
@EXPORT_OK= qw ();
%EXPORT_TAGS=();
###

sub readTRANSFAC {
    #Reads the input TRANSFAC file
    my $file=shift @_;
    my @PWM;
    my $name;
    local $/="XX";
    open(my $fh,"<",$file)
        or die $!;
    while(<$fh>){
        chomp;
        if (m/^\nDE\s+(\w.*)\n/){
            $name=$1;
            last;
        }
    }
    <$fh>;
    local $/="\n";
    while (<$fh>){
        chomp;
        if(m/^(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/){
            $PWM[$1-1][0]=$2;
            $PWM[$1-1][1]=$3;
            $PWM[$1-1][2]=$4;
            $PWM[$1-1][3]=$5;
            }
    }
    close $fh;
    $name=lc $name;
    $name =~ s/ /-/g;
    return (\@PWM,$name);
}

sub numbersequences {
    #Calculates the possible number of sequences that can be obtained from a matrix 
    my $PWMref=$_[0];
    my @possib_array;
    my $count=0;
    my $n=scalar @{$PWMref};
    my $m=scalar @{@{$PWMref}[0]};
    for (my $i=0;$i<$n;$i++){
        for (my $j=0;$j<$m;$j++){
            if (${@{$PWMref}[$i]}[$j] > 0){$count++;}
        }
        push @possib_array,$count;
        $count=0;
    }
    my $nseq=1;
    foreach my $number (@possib_array){
        $nseq *= $number;
    }
    return $nseq;
}

sub genmat {
    #Sorts the columns of the matrix
    my ($PWMref,$orign_order_ref)=@_;
    my $n=scalar @{$PWMref};
    my $m=scalar @{@{$PWMref}[0]};
    my @PWM2;
    for (my $i=0;$i<$n;$i++){
        for (my $j=0;$j<$m;$j++){
            $PWM2[$i][$j]=${@{$PWMref}[$i]}[$j].".".${$orign_order_ref}[$j];
        }
    }
    for (my $i=0;$i<$n;$i++){
        @{$PWM2[$i]}=sort compare @{$PWM2[$i]};
    }
    return @PWM2;
}

sub compare{
    #Auxiliar function used with sort
    $a =~ m/(\d+)./;
    my $aa = $1;
    $b =~ m/(\d+)./;
    my $bb = $1;
    $bb <=> $aa;
}

sub sort_rows {
    #Get the optimal order of the rows
    my $PWMref=shift; 
    my $n=scalar @{$PWMref};
    my @first_col;
    my @order;
    for (my $ii=0;$ii<$n; $ii++){
        push @first_col,${@{$PWMref}[$ii]}[0].".".$ii;
    } 
    my @order= sort compare @first_col;
    #Split the two components of @order
    my $element;
    for (my $ij=0;$ij<scalar @order; $ij++){
        $element=shift(@order);
        (my $i,my $j)=split(/\./,$element);
        push @order,$j;
    }
    return @order;
}

sub swap_rows {
    #Swap the rows of the matrix according to a given order
    my ($array,$order)=@_;
    my $n=scalar @{$order};
    my @ordered_array;
    for (my $ij=0;$ij<$n;$ij++){
        @{$ordered_array[$ij]}=@{@{$array}[${$order}[$ij]]};
    }
    return @ordered_array;
}

sub genseq{
    #Recursive function to generate sequences
    my ($PWMref,$nuclref,$orderref,$array_seqsref,$row,$M,$nseq,$genseq,$lastcolindex,$heuristiciter,$S,$lastscore,$niter,$fileout,$sens)=@_;
    my $n=scalar @{$PWMref};
    my $m=scalar @{@{$PWMref}[0]};
    if ($row >= $n){return;}
    if (($n+1) % 2 == 0 and $row == 0 ){
        #If the matrix has an odd number of rows we start by enumerating the nodes for the first row so that the last one can be paired using the branch function
        my $col=0;
        foreach my $node (@{${$PWMref}[$row]}){
            if ($node > 0 ){
                ${$lastcolindex}[$row]=$col;
                genseq($PWMref,$nuclref,$orderref,$array_seqsref,$row+1,$M,$nseq,$genseq,$lastcolindex,$heuristiciter,$S,$lastscore,$niter,$fileout,$sens);
            }
        $col++;
        }
    }
    else{
        my $nodes=branch($PWMref,$lastcolindex,$row);
        foreach my $node (@{$nodes}){
            ${$lastcolindex}[$row]=${$node}[1];
            ${$lastcolindex}[$row+1]=${$node}[2];
            if ($row+1 == $n-1){
                #Exit of the recursion function 
                my $seq=getseq($nuclref,$lastcolindex,$orderref);
                my $score=getscore($PWMref,$lastcolindex);
                $$genseq++;
                push @{$array_seqsref},[$score,$seq];
                if ($score >= $$lastscore-$$sens){
                    $$heuristiciter=1;
                }
                if ($$genseq % ($M*10) == 0){
                    #Keep the stack at a reasonable size
                    #Useful if need large amount of sequences
                    sort_array($array_seqsref,$lastscore,$M);
                }
                if ($$genseq == ($$M+$$niter*$$S) ){
                    #End of iteration of the heuristic algorithm
                    $$niter++;
                    sort_array($array_seqsref,$lastscore,$M);
                    if (!$$heuristiciter or $$S == 0){
                        #Iteration ended without finding a better sequence than the last
                        #Exiting the function
                        print_sequences($array_seqsref,$$M,$$fileout); 
                        exit(0);
                    }
                    else{
                        #Prepare for the next iteration
                        $$heuristiciter=0; 
                    }
                }
            }
            else{
                genseq($PWMref,$nuclref,$orderref,$array_seqsref,$row+2,$M,$nseq,$genseq,$lastcolindex,$heuristiciter,$S,$lastscore,$niter,$fileout,$sens);
            }
       }
       return;
    }
}

sub print_sequences {
    #Print the M best sequences from the stack
    my ($array_seqs,$M,$fileout)=@_;
    my $fh;
    if ($fileout){
        open($fh,"> $fileout") or die $!;
    }
    else{
        $fh=\*STDOUT;
    }
    print $fh "Sequence\tScore\n";
    my $ii=0;
    while ($ii<$M){
        print $fh "${${$array_seqs}[$ii]}[1]\t${${$array_seqs}[$ii]}[0]\n";
        $ii++;
    }
    return 1;
}

sub sort_array {
    #Sort and clean the stack
   my ($array_seqsref,$lastscore,$M)=@_; 
    @{$array_seqsref}=sort compare_array @{$array_seqsref};
    $$lastscore=${${$array_seqsref}[$$M-1]}[0];
    splice @{$array_seqsref},$$M;
    return 1;
}

sub compare_array {
    #Auxiliar function for the sort command
    if (${$b}[0]<${$a}[0]){
        return -1;
    }
    elsif (${$b}[0]>${$a}[0]){
        return 1;
    }
    else{
        ${$a}[1] cmp ${$b}[1];
    }
}
sub getscore{
    #Put together the score of the sequence
    my ($scoreref,$lastcolindex)=@_;
    my $n=scalar @{$lastcolindex};
    my $score=0;
    my $ii=0;
    while($ii < $n){
        $score += ${@{$scoreref}[$ii]}[${$lastcolindex}[$ii]];
        $ii++;
    }
    return $score;
}
sub getseq{
    #Put together the nucleotides of the sequence
    my ($nuclref,$lastcolindex,$orderref)=@_;
    my $n=scalar @{$lastcolindex};
    my @seq;
    my $ii=0;
    while($ii < $n){
        $seq[${$orderref}[$ii]]=${@{$nuclref}[$ii]}[${$lastcolindex}[$ii]];
        $ii++;
    }
    return join("",@seq);
}

sub branch{
    #Reads two leves and sorts the possible child nodes for the two levels
    my ($scoresref,$lastcolindex,$row,$col)=@_; 
    my $n=scalar @{${$scoresref}[$row]};
    my @aux_array;
    my $ii=0;
    my $jj=0;
    while ($ii < $n){
        my $p1=${${$scoresref}[$row]}[$ii];
        unless ( $p1 > 0){last;}
        while ($jj <$n){
            my $p2=${${$scoresref}[$row+1]}[$jj];
            unless ($p2 > 0){last;}
                push @aux_array,[$p1+$p2,$ii,$jj]; 
            $jj++;
        }
        $ii++;
        $jj=0;
    }
    my @return_list=sort {${$b}[0] <=> ${$a}[0]} @aux_array;
    return \@return_list;
}
###
1;
