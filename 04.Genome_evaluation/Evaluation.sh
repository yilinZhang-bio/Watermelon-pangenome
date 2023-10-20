1. BUSCO
   busco -i genome.fasta  -l embryophyta_odb10 -o busco -m genome --cpu 2
   busco -i longest_isoform.fasta  -l embryophyta_odb10 -o busco -m prot --cpu 2

2. N50 length
   java -jar gnx.jar genome.fasta >genome.fasta.N50

3. qualimap2
   bwa index genome.fasta
   bwa mem -t 128 -M genome.fasta ${Sample}_1_clean.fq.gz ${Sample}_2_clean.fq.gz >${Sample}.sam
   samtools view -@ 12 -bS ${Sample}.sam -o ${Sample}.bam
   samtools sort -@ 12 ${Sample}.bam -o ${Sample}.sort.bam
   qualimap bamqc -bam ${Sample}.sort.bam -nt 12 --java-mem-size=80G -c -outdir ./${Sample}
   minimap2 -t 12 -ax asm20 genome.fasta ${Sample}.ccs.fasta > ${Sample}.minimap.sam
   samtools view -@ 12 -bS ${Sample}.minimap.sam -o ${Sample}.minimap.bam
   samtools sort -@ 12 ${Sample}.minimap.bam -o ${Sample}.minimap.sort.bam
   qualimap bamqc -bam ${Sample}.minimap.sort.bam -nt 128 --java-mem-size=80G -c -outdir ./${Sample}

4. QV
   meryl k=21 count output ${Sample}_1.meryl ${Sample}_1_clean.fq.gz threads=12
   meryl k=21 count output ${Sample}_2.meryl ${Sample}_2_clean.fq.gz threads=12
   meryl union-sum output ${Sample}.meryl ${Sample}_*.meryl threads=12
   merqury.sh ${Sample}.meryl genome.fasta QV_${Sample}
   
5. LAI
   gt suffixerator -db genome.fasta -indexname ${Sample} -tis -suf -lcp -des -ssp -sds -dna
   gt ltrharvest -index ${Sample} -minlenltr 100 -maxlenltr 7000 -mintsd 4 -maxtsd 6 -motif TGCA -motifmis 1 -similar 85 -vic 10 -seed 20 -seqids yes > ${Sample}.harvest.scn
   LTR_FINDER_parallel -seq genome.fasta -threads 30 -harvest_out -size 1000000
   cat ${Sample}.harvest.scn genome.fa.finder.combine.scn > genome.fa.rawLTR.scn
   LTR_retriever -genome genome.fasta -inharvest genome.fa.rawLTR.scn -threads 40
   LAI -genome genome.fasta -intact genome.fa.pass.list -all genome.fa.out -t 20
