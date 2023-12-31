library(HiTC)
hiC<-importC("rawdata_50000.matrix",xgi.bed="rawdata_50000_abs.bed")
hiC01 <- extractRegion(hiC$ChrChr, chr="Chr", from=0, to=length)
pc <- pca.hic(hiC01, normPerExpected=TRUE, method="loess", npc=1)
pc <- pca.hic(hiC01, normPerExpected=TRUE, method="mean", npc=1)
pdf("HiTC.pdf")
plot(start(pc$PC1), score(pc$PC1), type="h", xlab="Chr", ylab="PC1vec", frame=FALSE)
dev.off()
write.table(pc$PC1,file="HiTC.txt",quote=FALSE,sep="\t")

