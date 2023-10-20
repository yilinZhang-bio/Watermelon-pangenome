09. Structural variation identification
nucmer ${REF} ${QUERY} -t 30 -c 100 -b 500 -l 50 –maxmatch -p ${REF}_${QUERY}
delta-filter -m -i 90 -l 100 ${REF}_${QUERY}.delta >${REF}_${QUERY}.filter.delta
syri --nc 20 -c ${REF}_${QUERY}.fil.coords -d ${REF}_${QUERY}.fil.delta -r ${REF} -q ${QUERY}
anchorwave gff2seq -i ${REF}.gff -r ${REF}.fa -m 0 -o cds.fa
gmap_build --dir=./${REF} --db=${REF} ${REF}.fa
gmap_build --dir=./${QUERY} --db=${QUERY} ${QUERY}.fa
gmap -t 10 -A -f samse -d ${REF} -D ${REF}/ cds.fa > gmap_${REF}.sam
gmap -t 10 -A -f samse -d ${QUERY} -D ${QUERY} cds.fa > gmap_${QUERY}.sam
anchorwave genoAli -i ${REF}.gff -as cds.fa -r ${REF}.fa -a ${QUERY}.sam -ar ${REF}.sam -s ${QUERY}.fa -v ${QUERY}.vcf -n ${QUERY}.anchors -o ${QUERY}.maf -f ${QUERY}.f.maf -m 0 > ${QUERY}.log

