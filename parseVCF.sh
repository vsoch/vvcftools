#!/usr/bash

# This script takes as input a folder with vcf files and an output folder, and does the following:

# parseVCF.sh -------------------------------------------------------------------------------------------------------
# 1) Compile all vcfs into one
# 2) Filter down to calls with good quality
# 3) Write ALL variants into a big matrix! 

#:INPUT ARGUMENTS
#   INFOLDER: an input folder with VCFs
#   OUTFOLDER: an output folder for the tab delimited matrix of variants.  You MUST specify a unique output folder
#     for each analysis, as old files will be overwritten

#:USAGE
#   parseVCF.sh /home/vanessa/Documents/Work/tutorial/vcf/input /home/vanessa/Documents/Work/vcf/output

#:OUTPUT
# vcf_merged_all.vcf.gz     Zipped file of all vcfs
# vcf_merged_filter         Filtered to only include those with min DP: 10, min GQ: 20
# vcf_merged_pass           Filtered to only those with "PASS"
#                           For both of the above, as both .vcf.gz and tab separated (.tab)


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


# Read input arguments
INFOLDER=$1
OUTFOLDER=$2

# Exit if there are not two input arguments
if [ "$#" -ne 2 ]; then
    echo "Pleases specify input vcf directory and output directory as input arguments!"
fi

# Check that we have tabix, vcftools installed
type tabix >/dev/null 2>&1 || { echo >&2 "Please install tabix and add to path."; exit 1; }
type vcftools >/dev/null 2>&1 || { echo >&2 "Please install vcftools and add to path."; exit 1; }

# Check that perl directory environment variable is set
if env | grep -q ^PERL5LIB=
then
  echo "environment variable for perl is exported, good job."
else
  echo "environment variable for perl folder in vcftools was not exported"
fi

# Check that we have vcf files in the directory
VCFS=(`ls $INFOLDER/*.vcf`)

if [ "${#VCFS[@]}" -lt 1 ]; then
  echo "No vcf files found in folder."
  exit 1
else
  echo "Found" ${#VCFS[@]} "vcf files."
fi

# Check vcf file formatting

# Convert to tabix format
for i in ${VCFS[@]}; do
  bgzip $i
  tabix -p vcf $i".gz"
done

# /home/sgsharma/workspace/1000_genomes_analysis/commonVarOverlap.R

# Merge into one file
vcf-merge $INFOLDER/*.vcf.gz | bgzip -c > $OUTFOLDER/vcf-merged.vcf.gz


# Now let's do filtering, based on Jack's specifications
# min DP: 10
# min GQ: 20 (we used to use 30 but now we are going with 20)

# Try doing two ways - 1) filtering out all that don't pass, 2) filtering out specific thresholds
vcftools --gzvcf $OUTFOLDER/vcf-merged.vcf.gz --remove-filtered-all --recode --stdout | gzip -c > $OUTFOLDER/vcf_merged_pass.vcf.gz
vcftools --gzvcf $OUTFOLDER/vcf-merged.vcf.gz  --min-meanDP 10 --minGQ 20 --recode --stdout | gzip -c > $OUTFOLDER/vcf_merged_filter.vcf.gz

# Finally, write to a tab delimited matrix for working with in R
zcat $OUTFOLDER/vcf_merged_pass.vcf.gz | vcf-to-tab > $OUTFOLDER/vcf_merged_pass.tab
zcat $OUTFOLDER/vcf_merged_filter.vcf.gz | vcf-to-tab > $OUTFOLDER/vcf_merged_filter.tab

# The output is a complete file of good quality genotypes.  
# The next step (the R script filterToRare.R) reads in the output above and filters to those at < 1% of 1000 genomes
