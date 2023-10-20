---
title: "Genome alignment using AnchorWave"
author: "Baoxing Song"
date: "`r format(Sys.Date(), '%Y-%m-%d')`"
output:
  BiocStyle::pdf_document:
    highlight: zenburn
    number_sections: yes
    toc: yes
    toc_depth: 4
---

```{r wrap-hook, include=FALSE}
library(knitr)
hook_output = knit_hooks$get('output')
knit_hooks$set(output = function(x, options) {
  # this hook is used only when the linewidth option is not NULL
  if (!is.null(n <- options$linewidth)) {
    x = knitr:::split_lines(x)
    # any lines wider than n should be wrapped
    if (any(nchar(x) > n)) x = strwrap(x, width = n)
    x = paste(x, collapse = '\n')
  }
  hook_output(x, options)
})
```



```{r include=FALSE}
options(tinytex.verbose = TRUE)
```

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
knitr::opts_chunk$set(fig.pos = 'H')
def.chunk.hook  <- knitr::knit_hooks$get("chunk")
knitr::knit_hooks$set(chunk = function(x, options) {
  x <- def.chunk.hook(x, options)
  ifelse(options$size != "normalsize", paste0("\\", options$size,"\n\n", x, "\n\n \\normalsize"), x)
})
```

minimap2 v 2.17-r941
anchorwave v1.2.1


```{r engine = 'bash', eval = FALSE, size="tiny"}
anchorwave gff2seq -r ./Genome/G42.nogap.v4.fasta -i ./Gff3/EVM.filter.rename.gff3 -o cds.fa
```

### Map full-length CDS to reference and query genomes
```{r engine = 'bash', eval = FALSE, size="tiny"}
minimap2 -x splice -t 11 -k 12 -a -p 0.4 -N 20 ./Genome/G42.nogap.v4.fasta cds.fa > ref.sam
minimap2 -x splice -t 11 -k 12 -a -p 0.4 -N 20 ./Genome/Allsugar.genome.fasta cds.fa > Allsugar.sam
```

```{r engine = 'bash', eval = FALSE, size="tiny"}
anchorwave proali -i ./Gff3/EVM.filter.rename.gff3 -r ./Genome/G42.nogap.v4.fasta -a Allsugar.sam -as cds.fa -ar ref.sam -s ./Genome/Allsugar.genome.fasta -n Allsugar.anchors -R 1 -Q 1 -ns

anchorwave genoAli -i ./Gff3/EVM.filter.rename.gff3 -r ./Genome/G42.nogap.v4.fasta -a Allsugar.sam -as cds.fa -ar ref.sam -s ./Genome/Allsugar.genome.fasta -n Allsugar.v2.anchors

```

```{r  warning=FALSE, fig.height = 140, fig.width = 220, size="tiny"}
library(ggplot2)
library(compiler)
enableJIT(3)
library(ggplot2)
library("Cairo")
changetoM <- function ( position ){
  position=position/1000000;
  paste(position, "M", sep="")
}
data =read.table("Allsugar.anchors", head=TRUE)
data = data[which(data$refChr %in% c("Chr01", "Chr02", "Chr03", "Chr04", "Chr05", "Chr06", "Chr07", "Chr08", "Chr09", "Chr10", "Chr11")),]
data = data[which(data$queryChr %in% c("Chr01", "Chr02", "Chr03", "Chr04", "Chr05", "Chr06", "Chr07", "Chr08", "Chr09", "Chr10", "Chr11")),]
data$refChr = factor(data$refChr, levels=c("Chr01", "Chr02", "Chr03", "Chr04", "Chr05", "Chr06", "Chr07", "Chr08", "Chr09", "Chr10", "Chr11" ))
data$queryChr = factor(data$queryChr, levels=c("Chr01", "Chr02", "Chr03", "Chr04", "Chr05", "Chr06", "Chr07", "Chr08", "Chr09", "Chr10", "Chr11" ))

AllsugarPlot = ggplot(data=data, aes(x=queryStart, y=referenceStart))+geom_point(size=0.5, aes(color=strand))+
    facet_grid(refChr~queryChr, scales="free", space="free" )+ theme_grey(base_size = 120) +
    labs(x="Allsugar", y="G42")+scale_x_continuous(labels=changetoM) + scale_y_continuous(labels=changetoM) +
    theme(axis.line = element_blank(),
          panel.background = element_blank(),
          panel.border = element_rect(fill=NA,color="black", size=0.5, linetype="solid"),
          axis.text.y = element_text( colour = "black"),
          legend.position='none',
          axis.text.x = element_text(angle=300, hjust=0, vjust=1, colour = "black") )

CairoPDF(file="AllsugarPlot.pdf",width = 90, height = 90)
AllsugarPlot
dev.off()

CairoPNG(file="AllsugarPlot.png",width = 9600, height = 9600)
AllsugarPlot
dev.off()

```



```{r  warning=FALSE, fig.height = 140, fig.width = 220, size="tiny"}
library(ggplot2)
library(compiler)
enableJIT(3)
library(ggplot2)
library("Cairo")
changetoM <- function ( position ){
  position=position/1000000;
  paste(position, "M", sep="")
}
data =read.table("Allsugar.v2.anchors", head=TRUE)
data = data[which(data$refChr %in% c("Chr01", "Chr02", "Chr03", "Chr04", "Chr05", "Chr06", "Chr07", "Chr08", "Chr09", "Chr10", "Chr11")),]
data = data[which(data$queryChr %in% c("Chr01", "Chr02", "Chr03", "Chr04", "Chr05", "Chr06", "Chr07", "Chr08", "Chr09", "Chr10", "Chr11")),]
data$refChr = factor(data$refChr, levels=c("Chr01", "Chr02", "Chr03", "Chr04", "Chr05", "Chr06", "Chr07", "Chr08", "Chr09", "Chr10", "Chr11" ))
data$queryChr = factor(data$queryChr, levels=c("Chr01", "Chr02", "Chr03", "Chr04", "Chr05", "Chr06", "Chr07", "Chr08", "Chr09", "Chr10", "Chr11" ))

AllsugarPlot = ggplot(data=data, aes(x=queryStart, y=referenceStart))+geom_point(size=0.5, aes(color=strand))+
    facet_grid(refChr~queryChr, scales="free", space="free" )+ theme_grey(base_size = 120) +
    labs(x="Allsugar", y="G42")+scale_x_continuous(labels=changetoM) + scale_y_continuous(labels=changetoM) +
    theme(axis.line = element_blank(),
          panel.background = element_blank(),
          panel.border = element_rect(fill=NA,color="black", size=0.5, linetype="solid"),
          axis.text.y = element_text( colour = "black"),
          legend.position='none',
          axis.text.x = element_text(angle=300, hjust=0, vjust=1, colour = "black") )

CairoPDF(file="AllsugarPlot.v2.pdf",width = 90, height = 90)
AllsugarPlot
dev.off()

CairoPNG(file="AllsugarPlot.v2.png",width = 9600, height = 9600)
AllsugarPlot
dev.off()
```
