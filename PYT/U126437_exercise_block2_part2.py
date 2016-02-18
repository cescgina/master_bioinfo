from sequence_data import *


class Sequence(object):
    """ Object with atrributes identifier and sequence and methods:
        get_identifier, get_sequence, get_mw, has_subsequence"""

    def __init__(self, identifier, sequence):
        self.__identifier = identifier
        self.__sequence = sequence
        self.alphabet = ''
        self.weights = {}
        self.complem = {}

    def get_identifier(self):
        """ Return a string with the object identifier"""
        return self.__identifier

    def get_sequence(self):
        """Return a string with the object sequence"""
        return self.__sequence

    def check_seq(self):
        """"""
        for element in self.__sequence:
            try:
                element in self.alphabet
            except:
                raise ValueError(
                    "Impossible to create instance: X not possible")

    def get_mw(self):
        """Returns a float with the molecular weight of the protein"""
        weight = 0
        for letter in self.__sequence:
            # if the letter of the sequence doesn't match an aminoacid, it is
            # treated as an "error" and no weight is added
            try:
                weight += self.weights[letter]
            except:
                pass
        return weight

    def has_subsequence(self, subsequence_obj):
        """ Return a boolean, TRUE if subsequence is present in sequence,
        subsequence is an instance of Sequence"""
        return subsequence_obj.get_sequence().upper() in self.__sequence


class NucleotideSequence(Sequence):
    """Nucleotide object that inherits from sequence, may be DNA or RNA"""

    def __init__(self, identifier, sequence):
        super(NucleotideSequence, self).__init__(identifier, sequence)
        self.alphabet = ''
        self.complem = {}
        self.weights = {}
        self.cod_table = {}
        self.stop_cod = []
        self.start_cod = []

    def translate(self):
        """Method to translate the nucleotide sequence to a protein"""
        translated = ''
        sequence = self.get_sequence()
        if len(sequence) % 3 != 0:
            raise ValueError(
                "Sequence length is not multiple of 3, not possible to divide in triplets")
        for i in range(0, len(sequence)-3, 3):
            if sequence[i:i+3] in self.start_cod:
                starting = i
                break
        for i in range(starting, len(sequence)-3, 3):
            if sequence[i:i+3] in self.stop_cod:
                break
            translated += self.cod_table[sequence[i:i+3]]
        return ProteinSequence(self.get_identifier(), translated)


class DNASequence(NucleotideSequence):
    """DNA Nuclotide object inherits from NucleotideSequence, also has a method transcribe"""

    def __init__(self, identifier, sequence):
        super(DNASequence, self).__init__(identifier, sequence)
        self.alphabet = dna_letters
        self.weights = dna_weights
        self.complem = dna_complement
        self.cod_table = dna_table
        self.stop_cod = dna_stop_codons
        self.start_cod = dna_start_codons
        self.check_seq()

    def transcribe(self):
        """Method to transcribe the DNA sequence to RNA, returns RNASequence object"""
        return RNASequence(
            self.get_identifier(),
            self.get_sequence().replace(
                'T',
                'U'))


class RNASequence(NucleotideSequence):
    """"""

    def __init__(self, identifier, sequence):
        super(RNASequence, self).__init__(identifier, sequence)
        self.alphabet = rna_letters
        self.weights = rna_weights
        self.complem = rna_complement
        self.cod_table = rna_table
        self.stop_cod = rna_stop_codons
        self.start_cod = rna_start_codons
        self.check_seq()

    def reverse_transcribe(self):
        """Method to reverse transcribe the RNA sequence to DNA, returns DNASequence object"""
        return DNASequence(
            self.get_identifier(),
            self.get_sequence().replace(
                'U',
                'T'))


class ProteinSequence(Sequence):
    """Protein object, inherits from Sequence"""

    def __init__(self, identifier, sequence):
        super().__init__(identifier, sequence)
        self.alphabet = protein_letters
        self.weights = protein_weights
        self.prot2dna = dna_table_back
        self.check_seq()

    def dna_seq(self):
        """Method to reverse translate the protein sequence"""
        dnaseq = ''
        for aa in self.get_sequence():
            dnaseq += self.prot2dna[aa]
        dnaseq += self.prot2dna[None]
        return DNASequence(self.get_identifier(), dnaseq)


def FASTA_iterator(fasta_filename):
    """ Creates a generator to iterate trough a FASTA file, yielding Protein objects for each sequence"""
    file = open(fasta_filename, "r")
    seq = ''
    for line in file:
        if line[0] == ">":
            if seq != "":
                yield ProteinSequence(lastid, seq)
            seq = ''
            lastid = line.strip()[1:]
        else:
            seq += line.strip()
    if seq != "":
        yield ProteinSequence(lastid, seq)

if __name__ == "__main__":
    for protein in FASTA_iterator("trimmed_fasta_file.txt"):
        print(protein.get_identifier())
        print(protein.get_sequence())
        print(protein.get_mw())
        print(protein.has_subsequence(Sequence('anon', 'A')))
        DNA = protein.dna_seq()
        print(DNA.get_identifier())
        print(DNA.get_sequence())
        print(DNA.get_mw())
        print(DNA.has_subsequence(Sequence('anon', 'A')))
        RNA = DNA.transcribe()
        print(RNA.get_identifier())
        print(RNA.get_sequence())
        print(RNA.get_mw())
        print(RNA.has_subsequence(Sequence('anon', 'A')))
        DNA_back = RNA.reverse_transcribe()
        print(DNA_back.get_identifier())
        print(DNA_back.get_sequence())
        print(DNA_back.get_mw())
        print(DNA_back.has_subsequence(Sequence('anon', 'A')))
        prot = DNA.translate()
        print(prot.get_identifier())
        print(prot.get_sequence())
        print(prot.get_mw())
        print(prot.has_subsequence(Sequence('anon', 'A')))
        prot_back = RNA.translate()
        print(prot_back.get_identifier())
        print(prot_back.get_sequence())
        print(prot_back.get_mw())
        print(prot_back.has_subsequence(Sequence('anon', 'A')))
