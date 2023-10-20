07. Phylogenetic tree analyses

The identification of variants follows the standard GATK workflow, including hard filtering.

Use plink --indep-pairwise 2000 10 0.5 to filter the veriations.
Use beagle to phase and impute the missing genotypes.
Use mafft to align the sequence and then ‘FastTree -nt -gamma -boot 500’to make the phylogenetic tree.

VCF2Dis -KeepMF -InPut ${file}.vcf.gz -OutPut ${file}.p_dis.mat
fneighbor  -datafile p_dis.matrix -outfile tree.out1.txt -matrixtype s -treetype n -outtreefile tree.out2.tre

