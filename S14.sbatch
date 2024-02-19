#!/bin/bash
#SBATCH --job-name=S14
#SBATCH --time=72:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --chdir=$HOME

mkdir -p $(realpath ~/scratch/S14)
mkdir -p $(realpath ~/scratch/S14/BED)
mkdir -p $(realpath ~/scratch/S14/TSV)
mkdir -p $(realpath ~/scratch/S14/BWig)
mkdir -p $(realpath ~/scratch/S14/BAM)
export blacklist=$(realpath ~/nfs/blacklist)
export BED=$(realpath ~/scratch/S13) #BED
export BED_OUT=$(realpath ~/scratch/S14/BED)
export TSV=$(realpath ~/scratch/S14/TSV) #TSV
export BWig=$(realpath ~/scratch/S14/BWig) #BWig
export bam_files=$(realpath ~/scratch/S14/BAM) #S8 - ficheiros bam a incluir

srun cp $(realpath ~/scratch/S8/*) $(realpath ~/scratch/S14/BAM)

ls $bam_files/*.bam | awk -F'[/.]' '{print $(NF-1)}' > $bam_files/list_bam.txt
bam_samples=($(cat $bam_files/list_bam.txt))

ls $BED/*.narrowPeak | awk -F'[/.]' '{print $(NF-1)}' > $BED/list_bed.txt
echo "sort"
cat $BED/*.narrowPeak | srun shifter --image=argrosso/htstools:0.2.1 bedtools sort > $BED_OUT/sorted.bed ;
echo "merge"
cat $BED_OUT/sorted.bed | srun shifter --image=argrosso/htstools:0.2.1 bedtools merge > $BED_OUT/mergedpeaks.bed ;

echo "bedtools int-sort"

srun shifter --image=argrosso/htstools:0.2.1 bedtools intersect -v -a $BED_OUT/mergedpeaks.bed -b $blacklist/hg38.blacklist.bed > $BED_OUT/compartments_mergedpeaks_filt.bed ;
srun shifter --image=argrosso/htstools:0.2.1 bedtools sort -i $BED_OUT/compartments_mergedpeaks_filt.bed > $BED_OUT/compartments_mergedpeaks_filt_sort.bed ;

echo "cov"
srun shifter --image=rosmaninho/bamscale:3 BAMscale cov --bed $BED_OUT/compartments_mergedpeaks_filt_sort.bed \
--prefix ATAC_peaks.quant -o $TSV \
$(for bam_sample in ${bam_samples[*]};do echo --bam $bam_files/${bam_sample}.bam;done) \
-t $SLURM_CPUS_PER_TASK ;
echo "scale"
srun shifter --image=rosmaninho/bamscale:3 BAMscale scale -o $BWig \
$(for bam_sample in ${bam_samples[*]};do echo --bam $bam_files/${bam_sample}.bam;done) \
-t $SLURM_CPUS_PER_TASK ;

echo "Statistics for job $SLURM_JOB_ID:"
sacct --format="JOBID,Start,End,Elapsed,CPUTime,AveDiskRead,AveDiskWrite,MaxRSS,exitcode,derivedexitcode" -j $SLURM_JOB_ID

rm -rf `ls -la /tmp/ | grep 'aesousa' | awk ' { print $9 } '`
