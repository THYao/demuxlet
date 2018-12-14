# Tutorial for demuxlet/freemuxlet #

## 1. Introduction ##

### 1.1. Overview ###

This tutorial provides streamlined instructions for using the tool `demuxlet` and `freemuxlet`. For a more detailed description of all of the options available to use with `demuxlet` and `freemuxlet`, please refer to the README. `demuxlet` and `freemuxlet` have several dependencies please refer INSTALL and install all required packages. For detailed compilation instructions, see the `demuxlet/freemuxlet` README.

`demuxlet` and `freemuxlet` are two software tools to deconvolute sample identity and identify multiplets when multiple samples are pooled by barcoded single cell sequencing. If external genotyping data for each sample is available, `demuxlet` would be recommended. On the other hand, if external genotyping data is not available, the genotyping-free version demuxlet, `freemuxlet`, would be recommended. 

To reduce computation time, we need to run `dsc-pileup` before running `demuxlet` and `freemuxlet`. `dsc-pileup` is a software tool to pileup reads and corresponding base quality for  each overlapping SNPs and each barcode. By using pileup files, it would allow us to run demuxlet/freemuxlet pretty fast multiple times without going over the BAM file again. 

`dsc-pileup` requires the following input files:

1. a SAM/BAM/CRAM file produced by the standard 10x sequencing platform, or any other barcoded single cell RNA-seq (with proper `--tag-UMI` and `--tag-group`) options.
2. A VCF/BCF files containing (AC) and (AN) from referenced population (e.g. 1000g).

`dsc-pileup` would generate CEL, PLP, VAR and UMI files, and these files would become input files for `demuxlet` and `freemuxlet`. Each of them contains different information: 
1. CEL file contains the relation table between numerated ID and barcode
2. PLP file contains piled up read and base quality for each overlapping SNPs and barcode
3. VAR file contains the position, reference allele and allele frequency for each SNP. 
4. UMI file contains the position covered by each umi.

After running `dsc-pileup`, we could run `demuxlet` by using pileup files and external genotyping data as input. Therefore, `demuxlet` require the following input files:

1. Pileup files (CEL,VAR and PLP) produced by `dsc-pileup`.
2. a VCF/BCF file containing the genotype (GT), posterior probability (GP), or genotype likelihood (GL) to assign each barcode to a specific sample (or a pair of samples) in the VCF file.

Alternatively, `dsc-pileup` could also directly take SAM file without running `dsc-pileup`. In this case, `dsc-pileup` would require the following files:

1. a SAM/BAM/CRAM file produced by the standard 10x sequencing platform, or any other barcoded single cell RNA-seq (with proper `--tag-UMI` and `--tag-group`) options.
2. a VCF/BCF file containing the genotype (GT), posterior probability (GP), or genotype likelihood (GL) to assign each barcode to a specific sample (or a pair of samples) in the VCF file.

Since `freemuxlet` is the genotyping-free version `demuxlet`, it would only require pileup files and number of samples. Therefore, `freemuxlet` require the following input: 

1. Pileup files (CEL, PLP and VAR) from dsc-pileup 
2. Number of samples


### 1.2. Additional resources ###

The README for demuxlet and freemuxlet is available [here](https://github.com/statgen/demuxlet)

If you have questions about using demuxlet/freemuxlet or suggestions for future releases, please contact jimmie.ye@ucsf.edu.

## 2. Getting Started ##

### 2.1. Installing dependencies ###

First, install required dependencies for MacOS and linux: 
* MacOS: autoconf, automake, libtool, xz, curl
* linux: autoconf, automake, libtool, libbz2-dev, liblzma-dev, zlib1g-dev

### 2.2. Running dsc-pileup to generate pileup files###

Once installing all packages, you can run `dsc-pileup` with the following command:

```
$ ./dsc-pileup --sam /data/$bam --vcf /data/$ref_vcf --out /data/$pileup
```

Add bam file name for `$bam` and reference population vcf file name for `$vcf`. Use `<(zcat $vcf)` or `<(gzcat $vcf)` if vcf file is compressed

### 2.3. Running demuxlet###

After pileup files generated, you could run demuxlet by the following command:

```
$ ./demuxlet --plp /data/$pileup --vcf /data/$external_vcf --field $(GT or GP or PL) --out /data/$filename
```

Add pileup files name for `$pileup` and external genotype vcf file name for `$external_vcf`

The options for `--field` are individual genotypes (GT), posterior probability (GP), or genotype likelihood (PL). 

Alternatively, `demuxlet` could directly take SAM/BAM as input. In this case, you could run demuxlet by the following command:

```
$ ./demuxlet --sam /data/$bam --vcf /data/$external_vcf --field $(GT or GP or PL) --out /data/$filename
```

### 2.4. demuxlet output ###

The demuxlet software produces one output file.

1. `[prefix].best` file contains the assignments of the best droplet type (singlet: `SNG`; doublet: `DBL`; ambiguous: `AMB`) in the `DROPLET.TYPE` column and best sample identity (singlet: `ID1, ID1, alpha`; doublet: `ID1, ID2, alpha`; ambiguous: `ID1, ID2, alpha`) in the `BEST.GUESS` column for each cell barcode identified in the `BARCODE` column along with details of the statistics used to determine the best identity.

For complete descriptions of the columns in each output file, please see the demuxlet README.

### 2.5. Running freemuxlet ###

Similar to demuxlet, you can run `freemuxlet` by using pileup files as input and by the following command: 

```
$ ./freemuxlet --plp /data/$pileup --nsample $n --out /data/$filename
```


### 2.6. freemuxlet output ###

The freemuxlet software produces three output files.

1. `[prefix].clust1.samples.gz`
The .clust1.samples.gz file contains the assignments of the best droplet type (singlet: `SNG`; doublet: `DBL`; ambiguous: `AMB`) in the `DROPLET.TYPE` column and best sample identity (singlet: `ID1, ID1`; doublet: `ID1, ID2`; ambiguous: `ID1, ID2`) in the `BEST.GUESS` column for each cell barcode identified in the `BARCODE` column along with details of the statistics used to determine the best identity.
2. The `[prefix].clust1.vcf.gz` file contains the vcf file for each SNP with each sample.

For complete descriptions of the columns in each output file, please see the demuxlet/freemuxlet README.


## 3. Analyzing the sample dataset ##

### 3.1 Create directory and download datasets ###

Now, let's first download the data we need. We are now providing a one-stop-shop to download all of the data you need for the tutorial: https://ucsf.box.com/s/vg1bycvsjgyg63gkqsputprq5rxzjl6k. After downloading and unzipping (it's BIG), you should have a directory called `demuxlet_freemuxlet.tutorial`.

### 3.2 Run dsc-pileup ###

```
$ cd demuxlet_freemuxlet.tutorial
$ ./dsc-pileup --sam /data/jurkat_293t_downsampled_n500_full_bam.bam --vcf /data/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5.20130502.snps_shared.coding_exon_v25.reorder.autosomes.maf1.vcf.gz --out /result/dsc_pileup.jurkat_293t.pooled
```

### 3.3 Run demuxlet ###

```
$ cd demuxlet_freemuxlet.tutorial
$ ./demuxlet --plp /result/dsc_pileup.jurkat_293t.pooled --vcf /data/jurkat_293t_exons_only.vcf --field GT --out result/jurkat_293t_demuxlet.pooled
```

Or you could run demuxlet by taking SAM/BAM directly:

```
$ cd demuxlet_freemuxlet.tutorial
$ ./demuxlet --sam /data/urkat_293t_downsampled_n500_full_bam.bam --vcf /data/jurkat_293t_exons_only.vcf --field GT --out result/jurkat_293t_demuxlet
```

### 3.4 Run freemuxlet ###

```
$ cd demuxlet_freemuxlet.tutorial
$ ./freemuxlet --plp /result/dsc_pileup.jurkat_293t.pooled --nsample 2 --out result/jurkat_293t_freemuxlet.pooled
```

### 3.4 Compare the called genotypes vs transcriptome data ###

In this analysis, we will use R to produce a t-SNE (t-Distributed Stochastic Neighbor Embedding) plot of the cells from the 293T:Jurkat 10x experiment with the cells colored by the assignments from the demuxlet/freemuxlet pipeline.

```
library(ggplot2);
library(data.table);

## let's read in the barcodes
tsne <- fread("analysis_csv/tsne/projection.csv");
demuxlet <- fread("jurkat_293t_demuxlet.pooled.best");
freemuxlet <- fread(paste0("zcat < ", "jurkat_293t_freemuxlet.pooled.clust1.samples.gz"));
freemuxlet<- freemuxlet[order(freemuxlet$BARCODE),]

## let's filter for the barcodes that we sampled

df <- data.frame(tsne1=tsne$"TSNE-1"[na.omit(match(demuxlet$BARCODE,tsne$Barcode))], tsne2=tsne$"TSNE-2"[na.omit(match(demuxlet$BARCODE,tsne$Barcode))], doublet_dmux=sapply(demuxlet$DROPLET.TYPE,function(x){strsplit(x,",")[[1]][[1]]}),
cell.type_dmux=sapply(demuxlet$BEST.GUESS,function(x){strsplit(x,",")[[1]][[2]]}),
doublet_fmux=freemuxlet$DROPLET.TYPE,
cell.type_fmux=freemuxlet$BEST.GUESS)

ggplot(aes(tsne1,tsne2,color=cell.type_dmux),data=df)+geom_point()+ggtitle(‘Demuxlet Sample ID’)
ggplot(aes(tsne1,tsne2,color=cell.type_fmux),data=df)+geom_point()+ggtitle(‘Freemuxlet Sample ID’)
```

After this, you should get the following image for demuxlet and freemuxlet respectively:

![](https://github.com/THYao/demuxlet/blob/master/tutorial/Demuxlet_SampleID.png)
![](https://github.com/THYao/demuxlet/blob/master/tutorial/Freemuxlet_SampleID.png)

Let's also take a look at the doublets.

```
ggplot(aes(tsne1,tsne2,color=doublet_dmux),data=df)+geom_point()+ggtitle(‘Demuxlet Doublet’)
ggplot(aes(tsne1,tsne2,color=doublet_fmux),data=df)+geom_point()+ggtitle(‘Freemuxlet Doublet’)
```

After that, you should get the following image:

![](https://github.com/THYao/demuxlet/blob/master/tutorial/Demuxlet_Doublet.png)
![](https://github.com/THYao/demuxlet/blob/master/tutorial/Freemuxlet_Doublet.png)

## 4. Source of 293T and Jurkat VCF file. ##
1. 293T VCF
Source website:
http://hek293genome.org/v2/data.php
Source file:
http://bioinformatics.psb.ugent.be/downloads/genomeview/hek293/SNP/293T_RTG.vcf.gz
2. Jurkat VCF
Source website: https://zenodo.org/record/400615#.WYIh7IQrLIV
Source file: https://zenodo.org/record/400615/files/jurkat_final_variant_calls.tar.gz
3. 293T:jurkat VCF file generation
We used the CrossMap tool to liftover the 293T vcf file from hg18 to hg19. The tetraploid genotype for the Jurkat vcf was collapsed to a diploid genotype before being merged with the 293T vcf file and the resulting file was filtered to contain only the exon positions.
    

