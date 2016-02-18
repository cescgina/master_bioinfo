class Protein(object):
    """ Object with atrributes identifier and sequence and methods: get_identifier, get_sequence, get_mw, has_subsequence and get_lenght"""
    def __init__(self, identifier, sequence):
        self.identifier=identifier
        self.sequence=sequence

    def get_identifier(self):
        """ Return a string with the object identifier"""
        return self.identifier

    def get_sequence(self):
        """Return a string with the object sequence"""
        return self.sequence

    def get_mw(self):
        """Returns a float with the molecular weight of the protein"""
        aminoacid_mw = {'A': 89.09, 'C': 121.16, 'E': 147.13, 'D': 133.1, 'G': 75.07, 'F': 165.19, 'I': 131.18, 'H': 155.16, 'K': 146.19, 'M': 149.21, 'L': 131.18, 'N': 132.12, 'Q': 146.15, 'P': 115.13, 'S': 105.09, 'R': 174.2, 'T': 119.12, 'W': 204.23, 'V': 117.15, 'Y': 181.19}
        weight=0
        for letter in self.sequence:
            #if the letter of the sequence doesn't match an aminoacid, it is treated as an "error" and no weight is added
            try:
                weight+=aminoacid_mw[letter]
            except:
                pass
        return weight

    def has_subsequence(self,subsequence):
        """ Return a boolean, TRUE if subsequence is present in sequence"""
        return subsequence.upper() in self.sequence

    def get_length(self):
        """Return a integer with the length of the object's sequence"""
        return len(self.sequence)

def FASTA_iterator (fasta_filename):
    """ Creates a generator to iterate trough a FASTA file, yielding Protein objects for each sequence"""
    file=open(fasta_filename,"r")
    seq=''
    for line in file:
        if line[0]==">":
            if seq != "":
                yield Protein(lastid,seq)
            seq=''
            lastid=line.strip()[1:]
        else:
            seq += line.strip()
    if seq != "":
        yield Protein(lastid,seq)

if __name__ == "__main__":
    for protein in FASTA_iterator("example_fasta_file.txt"):
        print(protein)
        print(protein.get_identifier())
        print(protein.get_length())
        print(protein.get_sequence())
        print(protein.get_mw())
        print(protein.has_subsequence('A'))
