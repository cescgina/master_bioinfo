def FASTA_iterator (fasta_filename):
    """ Creates a generator to iterate trough a FASTA file"""
    file=open(fasta_filename,"r")
    seq=''
    for line in file:
        if line[0]==">":
            if seq != "":
                yield (lastid,seq)
                seq=''
                lastid=line.strip()[1:]
            else:
                lastid=line.strip()[1:]
        else:
            seq += line.strip()
    if seq != "":
        yield (lastid,seq)

def get_common_identifiers (fasta_filename1,fasta_filename2):
    """ Creates a dictionary that contains the intersection, the union and the difference of the identifiers in two FASTA files"""
    set1=set()
    for sequence in FASTA_iterator(fasta_filename1):
        set1.add(sequence[0].upper())

    set2=set() 
    for sequence2 in FASTA_iterator(fasta_filename2):
        set2.add(sequence2[0].upper())
    set_combinations={}
    set_combinations["intersection"]=set1.intersection(set2)
    set_combinations["union"]=set1.union(set2)
    set_combinations["file1_specific"]=set1.difference(set2)
    set_combinations["file2_specific"]=set2.difference(set1)
    return set_combinations

def get_longest_sequences_from_FASTA_file(fasta_filename):
    """ Reads a FASTA file, and returns the sequences that have maximal lenght, in a list of tuples with format (id,sequence) """
    sequences=FASTA_iterator(fasta_filename)
    seq_list=list(sequences)
    max_item=max(seq_list,key=lambda x: len(x[1]))
    max_len=len(max_item[1])
    filtered_list=list(filter(lambda x: len(x[1])==max_len,seq_list))
    return sorted(filtered_list,key=lambda x:x[0].upper())

def get_shortest_sequences_from_FASTA_file(fasta_filename):
    """ Reads a FASTA file, and returns the sequences that have minimal lenght, in a list of tuples with format (id,sequence) """
    sequences=FASTA_iterator(fasta_filename)
    seq_list=list(sequences)
    min_item=min(seq_list,key=lambda x: len(x[1]))
    min_len=len(min_item[1])
    filtered_list=list(filter(lambda x: len(x[1])==min_len,seq_list))
    return sorted(filtered_list,key=lambda x:x[0].upper())

def calculate_molecular_weight(fasta_filename):
    """ Create a dictionary with all the protein sequences in a FASTA file with the sequence id as the key and the molecular weight of the protein as the value """
    
    sequence_weights={}
    aminoacid_mw = {'A': 89.09, 'C': 121.16, 'E': 147.13, 'D': 133.1, 'G': 75.07, 'F': 165.19, 'I': 131.18, 'H': 155.16, 'K': 146.19, 'M': 149.21, 'L': 131.18, 'N': 132.12, 'Q': 146.15, 'P': 115.13, 'S': 105.09, 'R': 174.2, 'T': 119.12, 'W': 204.23, 'V': 117.15, 'Y': 181.19}
    sequences=FASTA_iterator(fasta_filename)
    for element in sequences:
        weight=0
        for letter in element[1]:
            #if the letter of the sequence doesn't match an aminoacid, it is treated as an "error" and no weight is added
            try:
                weight+=aminoacid_mw[letter]
            except:
                pass
        sequence_weights[element[0]]=weight
    return sequence_weights

if __name__ == "__main__":
    dict=get_common_identifiers("example_fasta_file.txt","example_fasta_file.txt")
    print(len(dict["file1_specific"]))
    print(len(dict["file2_specific"]))
    print(len(dict["intersection"]))
    print(len(dict["union"]))
    print(get_longest_sequences_from_FASTA_file("example_fasta_file.txt"))
    print(get_shortest_sequences_from_FASTA_file("example_fasta_file.txt"))
    weightdict=calculate_molecular_weight("example_fasta_file.txt")
