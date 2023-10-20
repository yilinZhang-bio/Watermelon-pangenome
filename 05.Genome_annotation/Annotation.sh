1. TE annotation
   perl EDTA.pl --genome genome.fasta --species others --overwrite 1 --sensitive 1 --anno 1 --evaluate 1 --threads 64
   RepeatMasker -e rmblast -s -gff -nolow -no_is -norna -lib genome.fasta.mod.EDTA.TElib.fa -pa 64 genome.fasta

2. Protein-coding gene structure prediction
   glimmerhmm genome.fasta -d trained_dir/watermelon -g -f -n 1 -o ${Sample}_glimmerhmm
   augustus --strand=both --genemodel=complete --singlestrand=false --noInFrameStop=true --protein=on --introns=on --start=on --stop=on --cds=on --codingseq=on --alternatives-from-sampling=true --gff3=on --outfile=${Sample}.gff --uniqueGeneId=true --species=Watermelon genome.fasta
   braker.pl --cores 48 --species=Watermelon --genome=genome.fasta --softmasking --workingdir=${Sample} --bam=${bam1},${bam2}... --gff3 --useexisting
   exonerate -q ${file} -t genome --model protein2genome --querytype protein --targettype dna --showvulgar FALSE --softmaskquery yes --softmasktarget TRUE  --minintron 30 --maxintron 10000 --showalignment FALSE --showtargetgff TRUE --geneseed 250 --score 800 --bestn 1 --verbose 0 --saturatethreshold 100 --dnahspthreshold 60 --dnawordlen 14 >${Sample}.gff
   stringtie -p 30 -o ${Sample}.merge.gtf ${Sample}.merge.bam
   gtf_genome_to_cdna_fasta.pl ${Sample}.merged.gtf genome.fasta > transcripts.fasta
   gtf_to_alignment_gff3.pl ${Sample}.merged.gtf > transcripts.gff3
   TransDecoder.LongOrfs -t transcripts.fasta
   TransDecoder.Predict -t transcripts.fasta
   cdna_alignment_orf_to_genome_orf.pl transcripts.fasta.transdecoder.gff3 transcripts.gff3 transcripts.fasta > transcripts.fasta.transdecoder.genome.gff3
   augustus_GFF3_to_EVM_GFF3.pl ${Sample}.augustus.gff > ${Sample}.augustus.gff3
   glimmerHMM_to_GFF3.pl ${Sample}.glimmerhmm.gff >${Sample}.glimmerhmm.gff3
   Exonerate_to_evm_gff3.pl ${Sample}.exonerate.gff >${Sample}.exonerate.gff3
   partition_EVM_inputs.pl --genome genome.fasta --gene_predictions ${Sample}.ABINITIO_PREDICTION.gff3 \
   --protein_alignments ${Sample}.exonerate.gff3 --transcript_alignments transcripts.fasta.transdecoder.genome.gff3 --segmentSize 100000 --overlapSize 10000 \
   --partition_listing partitions_list.out
   write_EVM_commands.pl --genome genome.fasta --weights `pwd`/weights.txt --gene_predictions ${Sample}.ABINITIO_PREDICTION.gff3 --protein_alignments ${Sample}.exonerate.gff3 
   --transcript_alignments transcripts.fasta.transdecoder.genome.gff3 --output_file_name evm.out  --partitions partitions_list.out > commands.list
   execute_EVM_commands.pl commands.list |tee run.log &
   recombine_EVM_partial_outputs.pl --partitions partitions_list.out --output_file_name evm.out
   convert_EVM_outputs_to_GFF3.pl  --partitions partitions_list.out --output evm.out  --genome genome.fasta
   find . -regex ".*evm.out.gff3" -exec cat {} \; > EVM.all.gff3

3. Non-coding RNA gene annotation
   tRNAscan-SE -o ${Sample}.tRNA.out -f ${Sample}.tRNA.ss -m ${Sample}.tRNA.stats -a ${Sample}.tRNA.fa genome.fasta --thread 20
   rnammer -S euk -multi -f rRNA.fasta -h rRNA.hmmreport -xml rRNA.xml -gff rRNA.gff2 genome.fasta 
   cmscan -Z 100 --cut_ga --rfam --nohmmonly --tblout ${Sample}.tblout --fmt 2 --cpu 20 --clanin Rfam.clanin Rfam.cm genome.fasta > genome.cmscan
   perl infernal-tblout2gff.pl --cmscan --fmt2 genome.tblout >genome.infernal.ncRNA.gff3

4. Gene function annotation
   makeblastdb -in all.plant.protein.faa -dbtype prot -parse_seqids -title RefSeq_plant -out plant
   makeblastdb -in uniprot_sprot.fasta -dbtype prot -title swiss_prot -parse_seqids out swiss_prot
   blastp -query ${Sample}.protein.fa -out ${Sample}.swiss_prot.xml -db swiss_prot -evalue 1e-5 -outfmt 5 -num_threads 20
   blastp -query ${Sample}.protein.fa -out ${Sample}.RefSeq_plant.xml -db plant -evalue 1e-5 -outfmt 5 -num_threads 20 
   interproscan.sh -f TSV,XML,GFF3 -goterms -cpu 1 -i ${Sample} -iprlookup -pa -T ${Sample}_temp -b ${Sample}

