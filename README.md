# Vanessa VFC Tools

Vanessa VCF tools use the vcftools and tabix to do the following:

- Compile a folder of vcf files into one
- Filter down to calls with good quality
- Write all these variants into a big matrix
- Export as both zipped vcf and tab separated file
- Filter based on frequency (< 1% in 1000 genomes)

# parseVCF.sh
- Compile a folder of vcf files into one
- Filter down to calls with good quality
- Write all these variants into a big matrix
- Export as both zipped vcf and tab separated file

## Input arguments
#   INFOLDER: an input folder with VCFs
#   OUTFOLDER: an output folder for the tab delimited matrix of variants

## Usage
parseVCF.sh /home/vanessa/Documents/Work/tutorial/vcf/input /home/vanessa/Documents/Work/vcf/output


# filterToRare.R
- Filter based on frequency (< 1% in 1000 genomes)

## Required Files
1000_genomes_genotype_freq.frq in the same folder - a file of allele frequencies produced from a reference sequence

This file was produced on Sherlock with a compressed vcf with genotypes for all of 1000 genomes using tabix:

tabix -fh ALL.2of4intersection.20100804.genotypes.vcf.gz > 1000_genomes_all_genotypes.vcf

Then we calculate frequencies:

vcftools --vcf 1000_genomes_all_genotypes.vcf --freq --out 1000_genomes_genotype_freq

For future note, references are here:
ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release

