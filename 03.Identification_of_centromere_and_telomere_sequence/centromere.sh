trf genome1.fa 2 7 7 80 10 50 2000 -f -d -m -l 15
cd-hit -i genome1_filt.fa -o genome1_filt1.out -c 0.8 -T 4 -n 4 -d 30
Use mafft to align the sequence and then ‘FastTree -nt -gamma -boot 500’to make the phylogenetic tree.
