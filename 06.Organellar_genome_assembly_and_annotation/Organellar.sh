Organellar Genome Assembly and Annotation

get_organelle_from_reads.py -1 ${Sample}.WGS.R1.fastq.gz -2 ${Sample}.WGS.R2.fastq.gz -F embplant_pt -o plastome_output -R 10 -t 12 -k 21,45,65,85,105
get_organelle_from_reads.py -w 90 -1 ${Sample}.WGS.R1.fastq.gz -2 ${Sample}.WGS.R2.fastq.gz -F embplant_mt -o mitochondria_outputv -t 12 -R 30 -k 45,65,85,105,115

