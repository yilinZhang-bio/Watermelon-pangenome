
minigraph -cxggs -t64 ref.fa genome1.fa genome2.fa … > all_genome.gfa
vg construct
gfatools gfa2fa all_genome.gfa > all_genome.fa
vg construct -r ref.fa -v genome.vcf > all_genome.vg
vg view all_genome.vg > all_genome.gfa

