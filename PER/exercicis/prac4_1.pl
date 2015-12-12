#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

my $file='feats.gff';

open(my $fh,'<',$file) 
	or die $!;

my $line;
my @aux_array;
my @genes_array;
my %features;
while(<$fh>){
	$line=$_;
	chomp($line);
	@aux_array = split(/\s/, $line);
	if (exists($features{$aux_array[8]})){
		if (exists($features{$aux_array[8]}{$aux_array[2]})){
			$features{$aux_array[8]}{$aux_array[2]} += 1;
		}
		else{
			 $features{$aux_array[8]}{$aux_array[2]} = 1;
		 }
	}
	else{
		$features{$aux_array[8]}={$aux_array[2] => 1};
        push @genes_array,$aux_array[8];
	}
}
#print Dumper(%features{"AF245356.ENm001.+1"});
my $outfile="output4_1.txt";
open (my $fh2,">",$outfile)
    or die $!;
foreach my $key (@genes_array){
    print $fh2 $key . "\t";
    foreach my $seckey (keys %{$features{$key}}){
       print $fh2 $seckey . "\t" . $features{$key}{$seckey} . "\t"; 
    }
    print $fh2 "\n";
}
close $fh2;
