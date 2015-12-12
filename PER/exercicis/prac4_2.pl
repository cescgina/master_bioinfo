#!/usr/bin/perl
use strict;
use warnings;

my $file1='fileA.tbl';
open (my $fh,'<',$file1)
	or die $!;
my $line;
my %output;
my @aux_array;
while(<$fh>){
	$line = $_;
	chomp $line;
	@aux_array = split(/\s/, $line);
	if (not exists($output{$aux_array[0]})){
		$output{$aux_array[0]}=[$aux_array[1]," NA "];

	}
}
close($fh);

my $file2='fileB.tbl';
open (my $fh2,'<',$file2)
	or die $!;

while(<$fh2>){
	$line = $_;
	chomp $line;
	@aux_array = split(/\s/, $line);
	if (not exists($output{$aux_array[0]})){
		$output{$aux_array[0]}=[" NA ",$aux_array[1]];
	}
	else{
		@{$output{$aux_array[0]}}[1]=$aux_array[1];

	}
}
close($fh2);

my $out_file='output_4_2.txt';
open(my $fh3,'>',$out_file)
	or die $!;
my @key_arr= sort {$a <=> $b} keys %output;
print $fh3 "Id\tValueA\tValueB\n";
foreach my $k (@key_arr){
	print $fh3 join("\t",$k,@{$output{$k}}) . "\n";
}
close($fh3);
