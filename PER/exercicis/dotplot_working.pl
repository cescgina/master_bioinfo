#!/usr/bin/perl
use strict;
use warnings;

# Variables Declaration and Initialization
my @seq_array;
my $seq_name;
my %SEQS;
my $sequences;

# Get sequence names and input filename
# from command-line arguments
my $inputfile=pop @ARGV;
if (scalar @ARGV > 1){
	@seq_array=@ARGV;
}
else{
	@seq_array = split(/:/,$ARGV[0]);
}

# Load sequences from input file into a simple hash
#  (sequence names as keys,
#   sequence strings as the corresponding values)
open(FASTA,$inputfile);

while (<FASTA>) {
	chomp;
	if ($_ =~ m/>/){
		$seq_name = $_;
		$seq_name =~s/>//;
		(! exists $SEQS{$seq_name}) && do {$SEQS{$seq_name} = ''};
	}
	else{
		$SEQS{$seq_name} .= $_;
	}
}; # while

close(FASTA);

# Create the nxm matrix,
# load sequences on the left column and top row,
# set 0/1 values for match/mismatch respectively
my ($seqA, $seqB) = ($SEQS{$seq_array[0]}, $SEQS{$seq_array[1]});
                    # Choosing sequences to work with

$seqA = uc($seqA); # Ensuring all characters
$seqB = uc($seqB); # from the sequences are in upper case

my $n = length($seqA);
my $m = length($seqB);

my @MATRIX = (); # Initialize the matrix holder

$MATRIX[0][0] = q{*}; # The upper and leftmost cell
                      # does not contain data at all

# Now load sequences into the "zeroes" cells
for (my $j = 1; $j <= $n; $j++) {
    # Loops through columns and loads sequence A in row 0
    $MATRIX[$j][0] = substr($seqA,$j,1);
}; # for $j

for (my $i = 1; $i <= $m; $i++) {
    # Loops through rows and loads sequence B in column 0
    $MATRIX[0][$i] = substr($seqB,$i,1);
}; # for $j

# And finally, calculate identities/mismatches for each cell
$n++; # Increase length to include the sequence
$m++; # cells in the matrix, see below
for (my $j = 1; $j < $n; $j++) {
    # loop through rows (skip row 0 -> sequence holder)
    for (my $i = 1; $i < $m; $i++) {
    # loop through columns (skip col 0 -> sequence holder)
        if ($MATRIX[$j][0] eq $MATRIX[0][$i]) {
            $MATRIX[$j][$i] = 1; # match
        } else {
            $MATRIX[$j][$i] = 0; # mismatch
        };
     }; # for $j
}; # for $i

# Print to the terminal the Dot-Plot Matrix
for (my $j = 1; $j < $n; $j++) {
    # loop through rows
    for (my $i = 1; $i < $m; $i++) {
        # loop through columns
            # print dot-plot cells
            print STDOUT ($MATRIX[$j][$i] ? q{*} : q{ });
			print STDOUT $MATRIX[$j][$i];
        # print horizontal spacer
        print STDOUT q{ };
    }; # for $j
    # print rows
    print STDOUT "\n";
}; # for $i
exit(0);
