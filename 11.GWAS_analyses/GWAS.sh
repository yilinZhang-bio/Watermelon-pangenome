### GWAS
plink --vcf sample_id.vcf --recode 12 transpose --out emmax_in
emmax-kin emmax_in -v -d 10 -o emmax_in.BN.kinf
## k=2,3,4…
admixture –cv sample_id.ped k
## Try different k to find the optimal clustering and sort the Q matrix
emmax -t emmax_in -o emmax_out -p emmax_trait.txt -k emmax_in.BN.kinf -c emmax_cov.txt
