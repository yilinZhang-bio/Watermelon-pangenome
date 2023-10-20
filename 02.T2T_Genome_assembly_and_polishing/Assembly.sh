1. hifiasm -o ${Sample}.asm -t 40 ${Sample}.ccs.fasta

2. hifiasm -o ${Sample}.asm -t 128 --ul UL.fq.gz ${Sample}.ccs.fasta

3. lja -o ${Sample} --reads ${Sample}.ccs.fasta -t 24

4. hifiasm -o ${Sample}.asm -t 40 --write-paf --write-ec -l0 ${Sample}.ccs.fasta
   rbsa.py --type nucmer --ref REF --scf SCF
   filter.py --paf_fn PAF --bestn 20 --output OUTPUT
   chr_paths.py --agp AGP --gfa GFA
   ovlp2graph.py --overlap-file OVERLAP_FILE
   graph2chr.py --reads-fasta-fn READS_FASTA_FN --paf-fn PAF_FN --sg-edges-list-fn SG_EDGES_LIST_FN --ctg-paths-fn CTG_PATHS_FN

5. nextDenovo run.cfg

6. HiC-Pro -c config-hicpro.txt -o Analysis -i HIC_read

7. python2 HiCPlotter/HiCPlotter.py -f iced/1000000/sample1_1000000_iced.matrix -o ${Sample} -r 1000000 -tri 1 -bed sample1/raw/1000000/sample1_1000000_abs.bed -n ${Sample} -wg 1 -chr Chr11

8. ##get contig length
   perl fastaDeal.pl -attr id:len ${Sample}.contigs.fa > ${Sample} .contigs.fa.len 
   ##draw contig Hi-C heatmaps with 10*100000 (1-Mb) resolution
   matrix2heatmap.py ${Sample}_HiC_100000_abs.bed ${Sample}_HiC_100000.matrix 10
   ##Run one round, when the contig assembly is quite good
   perl endhic.pl ${Sample}.contigs.fa.len ${Sample}_HiC_100000_abs.bed ${Sample}_HiC_100000.matrix ${Sample}_HiC_100000_iced.matrix
   ln Round_A.04.summary_and_merging_results/z.EndHiC.A.results.summary.cluster* ./
   ##convert cluster file to agp file
   perl cluster2agp.pl Round_A.04.summary_and_merging_results/z.EndHiC.A.results.summary.cluster ${Sample}.contigs.fa.len > ${Sample}.scaffolds.agp
   ##get final scaffold sequence file
   perl agp2fasta.pl ${Sample}.scaffolds.agp ${Sample}.contigs.fa > ${Sample}.scaffolds.fa

9. ragtag.py scaffold $REF $SCF -o ./ragtag_default -t 26
   ragtag.py scaffold $REF $SCF -o ./ragtag_nucmer -t 26 --aligner 'nucmer'

10. ragtag.py patch $target $query

11.
## Screen out sequences containing telomere repeats
## For ont reads
minimap2 -t80 -x map-ont ref_genome.fasta candidate_telomere.fasta > ont_genome_tel.paf
## For hifi reads
minimap2 -t80 -x map-hifi ref_genome.fasta candidate_telomere.fasta > ont_genome_tel.paf
## Use paftools.js to process alignments in the PAF format. And use both Racon and Merfin algorithms to polish.

