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

    my $file=shift @_;
    my @PWM;
    open(my $fh,"<",$file)
        or die $!;
    while(<$fh>){
        chomp;
        if(m/(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/){
            $PWM[$1-1][0]=$2;
            $PWM[$1-1][1]=$3;
            $PWM[$1-1][2]=$4;
            $PWM[$1-1][3]=$5;
            }
    }
    close $fh;
    return @PWM;
}

sub numbersequences {
    
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
    my $PWMref=$_[0]; 
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
    my ($array,$order)=@_;
    my $n=scalar @{$order};
    my @ordered_array;
    for (my $ij=0;$ij<$n;$ij++){
        @{$ordered_array[$ij]}=@{@{$array}[@{$order}[$ij]]};
    }
    return @ordered_array;
}

sub genscores{
    my $PWMref=$_[0]; 
    my $N=0; 
    my $n=scalar @{$PWMref};
    my $m=scalar @{@{$PWMref}[0]};
    my @scoremat;
    foreach my $freq (@{@{$PWMref}[0]}){
        $N += $freq;
    }
    for (my $i=0;$i<$n;$i++){
        for (my $j=0;$j<$m;$j++){
            $scoremat[$i][$j]=${@{$PWMref}[$i]}[$j] / $N;
        }
    }
    return @scoremat;
}


sub genseq{
    my ($PWMref,$scoresref,$nuclref,$orderref,$seqref,$array_seqsref,$row,$M,$genseq,$lastcolindex)=@_;
    my $n=scalar @{$PWMref};
    my $m=scalar @{@{$PWMref}[0]};
    if ($row >= $n){return;}
    if ($row == $n-1){
        #Exit of the recursion function
        my $col=0;
        foreach my $node (@{${$PWMref}[$row]}){
            if ($node > 0 ){
                ${$lastcolindex}[$row]=$col;
                my $seq=getseq($nuclref,$lastcolindex,$orderref);
                #my $score=getscore($scoresref,$lastcolindex);
                my $score=getscore($PWMref,$lastcolindex);
                if (!exists(${$seqref}{$seq})){
                    #    print $seq;
                    #print "\t";
                    #printf ("%.15f",$score);
                    #print "\n";
                    ${$seqref}{$seq}=1;
                    $$genseq++;
                    my $last=${${$array_seqsref}[-1]}[0];
                    push @{$array_seqsref},[$score,$seq];
                    if ($last and $last < $score){
                        trim_array($array_seqsref,$seqref,$genseq);
                    }
                }
                if ($$genseq == $$M){
                    print_sequences($array_seqsref);
                    exit;
                }
            }
            $col++;
    }
        return;
}

    else{
#        my $nodes=branch($scoresref,$lastcolindex,$row);
        my $nodes=branch($PWMref,$lastcolindex,$row);
        foreach my $node (@{$nodes}){
            ${$lastcolindex}[$row]=${$node}[1];
            ${$lastcolindex}[$row+1]=${$node}[2];
            if ($row+1 == $n-1){
                if ($$genseq == $$M){
                    print_sequences($array_seqsref);
                    exit;
                }
                my $seq=getseq($nuclref,$lastcolindex,$orderref);
                #my $score=getscore($scoresref,$lastcolindex);
                my $score=getscore($PWMref,$lastcolindex);
                if (!exists(${$seqref}{$seq})){
                    #print $seq;
                    #print "\t";
                    #printf ("%.15f",$score);
                    #print "\n";
                    ${$seqref}{$seq}=1;
                    $$genseq++;
                    my $last=${${$array_seqsref}[-1]}[0];
                    push @{$array_seqsref},[$score,$seq];
                    if ($last and $last < $score){
                        trim_array($array_seqsref,$seqref,$genseq);
                    }
                }
                #else{
                #    print "$$genseq\n";
                #      print $seq;
                #      print "\t";
                #      printf ("%.15f",$score);
                #      print "\n";

                #}
            }
            else{
                genseq($PWMref,$scoresref,$nuclref,$orderref,$seqref,$array_seqsref,$row+2,$M,$genseq,$lastcolindex);
            }
       }
       return;
    }
}

sub print_sequences {
    my $array_seqs=shift;
    foreach my $seqref (@{$array_seqs}){
        print "${$seqref}[1]\t${$seqref}[0]\n";
    }
    return 1;
}

sub trim_array {
   my ($array_seqsref,$seqref,$genseq)=@_; 
    my $score=${${$array_seqsref}[-1]}[0];
    my $n=scalar @{$array_seqsref};
    my @array=@{$array_seqsref};
    @{$array_seqsref}=sort {${$b}[0] <=> ${$a}[0]} @{$array_seqsref};
    my $ii=0;
    while ($ii<$n){
        if( ${$array[$ii]}[0] < $score){
            last;
        } 
        $ii++;
    }
    #splice(@{$array_seqsref},$ii);
    undef %{$seqref};
    map {${$seqref}{${$_}[1]}=${$_}[0]} @{$array_seqsref};
    $$genseq=scalar @{$array_seqsref};
    return 1;
}
sub getscore{
    my ($scoreref,$lastcolindex)=@_;
    my $n=scalar @{$lastcolindex};
    my $score=0;
    my $ii=0;
    while($ii < $n){
        #$score *= ${@{$scoreref}[$ii]}[${$lastcolindex}[$ii]];
        $score += ${@{$scoreref}[$ii]}[${$lastcolindex}[$ii]];
        $ii++;
    }
    return $score;
}
sub getseq{
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
            #push @aux_array,[$p1*$p2,$ii,$jj]; 
                push @aux_array,[$p1+$p2,$ii,$jj]; 
            $jj++;
        }
        $ii++;
        $jj=0;
    }
    my @return_list=sort {${$b}[0] <=> ${$a}[0]} @aux_array;
    return \@return_list;
}

#sub genseq{
#    my ($PWMref,$scoresref,$nuclref,$orderref,$seqref,$row,$score,$M,$genseq)=@_;
#    my $n=scalar @{$PWMref};
#    my $m=scalar @{@{$PWMref}[0]};
#    if ($row == $n-1){
#        #Exit of the recursion function
#        for (my $j=0;$j<$m;$j++){ 
#            if (${@{$PWMref}[$row]}[$j] >0 ){
#                ${$seqref}[${$orderref}[$row]]=${@{$nuclref}[$row]}[$j];
#                #$score *= ${@{$scoresref}[$row]}[$j];
#                $score += ${@{$PWMref}[$row]}[$j];
#                print join("",@{$seqref});
#                print "\t";
#                printf ("%.15f",$score);
#                print "\n";
##                $score /= ${@{$scoresref}[$row]}[$j];
#                $score -= ${@{$PWMref}[$row]}[$j];
#                $$genseq++;
#                if ($$genseq == $$M){
#                    exit;
#                }
#            }
#            else {
#                next;
#            }
#        }
#        $score=1;
#    }
#    else{
#        for (my $j=0;$j<$m;$j++){
#            if (${@{$PWMref}[$row]}[$j] >0 ){
#                ${$seqref}[${$orderref}[$row]]=${@{$nuclref}[$row]}[$j];
#                #$score *= ${@{$scoresref}[$row]}[$j];
#                $score += ${@{$PWMref}[$row]}[$j];
#                genseq($PWMref,$scoresref,$nuclref,$orderref,$seqref,$row+1,$score,$M,$genseq);
#                #$score /= ${@{$scoresref}[$row]}[$j];
#                $score -= ${@{$PWMref}[$row]}[$j];
#            }
#            else {
#                next;
#            }
#        }
#    }
#    return;
#}
###
1;
