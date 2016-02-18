import sequence_data as data
import sys
import os


class Sequence(object):
    """ Object with atrributes identifier and sequence and methods:
        get_identifier, get_sequence, get_mw, has_subsequence"""

    alphabet = set()
    weights = {}
    complem = {}

    def __init__(self, identifier, sequence):
        self.__identifier = identifier
        self.__sequence = sequence
        self.__mw = None

    def __len__(self):
        return len(self.__sequence)

    def __eq__(self, other_seq):
        return self.__sequence.upper() == other_seq.get_sequence().upper()

    def __ne__(self, other_seq):
        return self.__sequence.upper() != other_seq.get_sequence().upper()

    def __add__(self, other_seq):
        if self.__class__ != other_seq.__class__:
            raise TypeError("Impossible to add the two sequences, %s and %s \
                            entered" % (self.__class__, other_seq.__class__))
        return self.__class__(self.__identifier+"_"+other_seq.get_identifier(),
                              self.__sequence+other_seq.get_sequence())

    def __getitem__(self, key):
        return self.__sequence[key]

    def __lt__(self, other_seq):
        return len(self.__sequence) < len(other_seq.get_sequence())

    def get_identifier(self):
        """ Return a string with the object identifier"""
        return self.__identifier

    def get_sequence(self):
        """Return a string with the object sequence"""
        return self.__sequence

    def check_seq(self):
        """"""
        for element in self.__sequence:
            if element not in self.alphabet:
                raise IncorrectSequenceLetter(element, self.__class__.__name__)

    def get_mw(self):
        """Returns a float with the molecular weight of the protein"""
        if self.__mw is None:
            self.__mw = 0
            for letter in self.__sequence:
                # if the letter of the sequence doesn't match an aminoacid,
                # it is treated as an "error" and no weight is added
                try:
                    self.__mw += self.weights[letter]
                except:
                    pass
        return self.__mw

    def has_subsequence(self, subsequence_obj):
        """ Return a boolean, TRUE if subsequence is present in sequence,
            subsequence is an instance of Sequence"""
        return subsequence_obj.get_sequence().upper() in self.__sequence


class NucleotideSequence(Sequence):
    """Nucleotide object that inherits from sequence, may be DNA or RNA"""

    cod_table = {}
    stop_cod = set()
    start_cod = set()

    def __init__(self, identifier, seq):
        super().__init__(identifier, seq)
        self.check_seq()

    def translate(self):
        """Method to translate the nucleotide sequence to a protein"""
        started = False
        translated_sequence = ""
        sequence = self.get_sequence()
        for i in range(0, len(sequence), 3):
            codon = sequence[i:i+3]
            if started is False:
                if codon in self.start_cod:
                    started = True
                    translated_sequence = self.cod_table[codon]
            elif codon in self.stop_cod:
                break
            else:
                translated_sequence += self.cod_table[codon]
        return ProteinSequence(self.get_identifier()+"_translated",
                               translated_sequence)


class DNASequence(NucleotideSequence):
    """DNA Nuclotide object inherits from NucleotideSequence,
        also has a method transcribe"""

    alphabet = set(data.dna_letters)
    weights = data.dna_weights
    complem = data.dna_complement
    cod_table = data.dna_table
    stop_cod = set(data.dna_stop_codons)
    start_cod = set(data.dna_start_codons)

    def __init__(self, identifier, seq):
        super().__init__(identifier, seq)
        self.check_seq()

    def transcribe(self):
        """Method to transcribe the DNA sequence to RNA,
            returns RNASequence object"""
        return RNASequence(self.get_identifier()+"_transcribed",
                           self.get_sequence().replace('T', 'U'))


class RNASequence(NucleotideSequence):
    """RNA Nucleotide inherits from NucleotideSequence,
        also has a method transcribe"""
    alphabet = set(data.rna_letters)
    weights = data.rna_weights
    complem = data.rna_complement
    cod_table = data.rna_table
    stop_cod = set(data.rna_stop_codons)
    start_cod = set(data.rna_start_codons)

    def __init__(self, identifier, seq):
        super().__init__(identifier, seq)
        self.check_seq()

    def reverse_transcribe(self):
        """Method to reverse transcribe the RNA sequence to DNA, returns
        DNASequence object"""
        return DNASequence(self.get_identifier()+"_transcribed",
                           self.get_sequence().replace('U', 'T'))


class ProteinSequence(Sequence):
    """Protein object, inherits from Sequence"""

    alphabet = set(data.protein_letters)
    weights = data.protein_weights
    prot2dna = data.dna_table_back

    def __init__(self, identifier, seq):
        super().__init__(identifier, seq)
        self.check_seq()

    def dna_seq(self):
        """Method to reverse translate the protein sequence"""
        dnaseq = ''
        for aa in self.get_sequence():
            dnaseq += self.prot2dna[aa]
        dnaseq += self.prot2dna[None]
        return DNASequence(self.get_identifier(), dnaseq)


def FASTA_iterator(fasta_filename):
    """ Creates a generator to iterate trough a FASTA file, yielding Protein
    objects for each sequence"""
    file = open(fasta_filename, "r")
    err = "There are sequences with incorrect elements in file %s\n"
    seq = ''
    lastid = ''
    for line in file:
        if line[0] == ">":
            if seq != "":
                try:
                    yield DNASequence(lastid, seq)
                except IncorrectSequenceLetter:
                    sys.stderr.write(err % (fasta_filename))
            seq = ''
            lastid = line.strip()[1:]
        else:
            seq += line.strip()
    if seq != "":
        try:
            yield DNASequence(lastid, seq)
        except IncorrectSequenceLetter:
            sys.stderr.write(err % (fasta_filename))


class IncorrectSequenceLetter(ValueError):

    def __init__(self, value, obj_class):
        self.value = value
        self.obj_class = obj_class

    def __str__(self):
        return "The sequence item %s is not found in the alphabet of class %s"\
            % (self.value, self.obj_class)


def fasta_processing(fasta, seqs):
    """Function to read FASTA file, tranform DNASequence to ProteinSequence and
    get the length and molecular weight"""
    for seq in FASTA_iterator(fasta):
        p = seq.translate()
        seqs.append([p.get_identifier(), len(p), p.get_mw()])
    return seqs


if __name__ == "__main__":

    outfile = ''
    infile = ''

    if len(sys.argv) == 1:
        # No inputs
        infile = list(os.popen("ls *.fa*"))
    elif len(sys.argv) == 2:
        # Only one argument, assume it is the input file or dir
        infile = sys.argv[1]
        if os.path.isdir(infile):
            infile = list(os.popen("ls *.fa*"))
    elif len(sys.argv) == 3:
        # Two arguments, input and output
        infile = sys.argv[1]
        if os.path.isdir(infile):
            infile = list(os.popen("ls *.fa*"))
        outfile = sys.argv[2]
    else:
        # Too many arguments, print usage string
        print("Too many arguments\nThe correct usage is:")
        print("python3 %s [IN] [OUT]" % (__name__))
        print("Arguments are optional, if input is not provided, the program \
              will search for all fasta files in the working directory")

    if infile.__class__ is not list:
        infile = [infile]

    n = len(infile)
    sys.stderr.write("%i FASTA files found\n" % n)
    seqs = []
    for fasta in infile:
        fasta = fasta.strip()
        seqs = fasta_processing(fasta, seqs)
        sys.stderr.write("%s finished\n" % fasta)

    sys.stderr.write("%i sequences found.\n" % len(seqs))
    sys.stderr.write("Sorting the sequences...\n")
    seqs.sort(key=lambda x: x[1], reverse=True)
    sys.stderr.write("Sort process finished\n")
    if outfile:
        f = open(outfile, "w")
        for seq in seqs:
            f.write("%s\t%i\t%f\n" % (seq[0], seq[1], seq[2]))
        f.close()
    else:
        for seq in seqs:
            sys.stdout.write("%s\t%i\t%f\n" % (seq[0], seq[1], seq[2]))
    sys.stderr.write("Program finished correctly\n")
