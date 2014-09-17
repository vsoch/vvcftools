# filterToRare.R --------------------------------------------------------------------------------------------------------
# 1) Filter output from parseVCF.sh down to rare variants (defined by less than 1% in 1000 genomes)

#:REQUIRED FILES
#   1000_genomes_genotype_freq.frq in the same folder - a file of allele frequencies produced from a reference sequence
#   see below for how this file was produced

#:INPUT ARGUMENTS
#   REFFREQ is a file of allele frequencies produced from a reference sequence (1000_genomes_genotype_freq.frq)

#:USAGE
#   RSCRIPT filterToRare.R 

#   EG: We have the frequency file for the 1000 genomes in same folder - produced from genotypes file on sherlock:
#   tabix -fh ALL.2of4intersection.20100804.genotypes.vcf.gz > 1000_genomes_all_genotypes.vcf
#   Then we calculate frequencies:
#   vcftools --vcf 1000_genomes_all_genotypes.vcf --freq --out 1000_genomes_genotype_freq

#   For future note, references are here:
#   ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release

