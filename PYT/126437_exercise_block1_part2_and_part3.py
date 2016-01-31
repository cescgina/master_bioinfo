def get_sequence_from_FASTA_file(filename,residue,threshold=0.3):
    """ Count the number of sequences in a FASTA file that have more than a certain residue frequency"""
    file=open(filename,"r")
    proteins={}
    for line in file:
        if line.startswith(">"):
            lastid=line.lstrip(">")
            lastid=lastid.rstrip()
            proteins[lastid]=''
        else:
            seq=line.rstrip()
            proteins[lastid] += seq
    file.close()
    numprots=0
    for prot in proteins:
        if (proteins[prot].count(residue))/len(proteins[prot]) >= threshold:
            numprots+=1
    return numprots

def print_sequence_tails(filename,first_n=10,last_m=10):
    """ Print the n first residues and the last m residues of the sequences in a FASTA file"""
    file=open(filename,"r")
    head=0
    seqtail=''
    tail=0
    remainfirst=0
    for line in file:
        if line.startswith(">"):
            if tail:
                print(seqtail[-last_m:])
                tail=0
                seqtail=''
            lastid=line.lstrip(">")
            lastid=lastid.rstrip()
            print(lastid + "\t", end='')
            head=1
        else:
            seq=line.rstrip()
            if head == 1:
                if remainfirst>0:
                    if remainfirst> len(seq):
                        print(seq),
                        remainfirst -= len(seq)
                    else:
                        print(seq[0:remainfirst]+"\t",end="")
                if len(seq)<first_n:
                    print(seq),
                    remainfirst=first_n-len(seq)
                else:
                    print(seq[0:first_n]+"\t",end="")
                    head=0
                    tail=1
            else:
                seqtail += seq
    if tail:
        print(seqtail[-last_m:])
        tail=0
        seqtail=''
    file.close()

def calculate_aminoacid_frequencies(fasta_filename, subsequences_filename, output_filename ):
    """ Calculate the fequencies of a series of subsequences in the sequences of a FASTA file """
    subs=open(subsequences_filename,"r")
    subsequences=[line.rstrip() for line in subs]
    subs.close()
    fasta=open(fasta_filename,"r")
    seq=''
    nprot=0
    subsdict={}
    for line in fasta:
        if line.startswith(">"):
            for subsequence in subsequences:
                if subsequence in seq:
                    try:
                        subsdict[subsequence]+=1
                    except: 
                        subsdict[subsequence]=1
            nprot+=1
            seq=''
        else:
            seq += line.rstrip()
    for subsequence in subsequences:
        if subsequence in seq:
            try:
                subsdict[subsequence]+=1
            except: 
                subsdict[subsequence]=1

    fasta.close()
    nsubs=len(subsequences)
    sorted_subs=sorted(subsdict.items(),key=lambda x:x[1],reverse=True)
    output=open(output_filename,"w")
    output.write("#Number of proteins: %d\n" % nprot)
    output.write("#Number of subsequences: %d\n" % nsubs)
    output.write("#subsequence proportions:\n")
    for element in sorted_subs:
        output.write(element[0].ljust(10)+"\t"+str(element[1]).rjust(10)+"\t"+"%.4f\n" % (element[1]/nprot))
    output.close()


if __name__ == "__main__":
#     print(get_sequence_from_FASTA_file("example_fasta_file.txt","A",0.05))
#     print_sequence_tails("example_fasta_file.txt")
     calculate_aminoacid_frequencies("example_fasta_file.txt","fragments_file.txt","output.txt")

