#!/bin/bash
#SBATCH --job-name=S6
#SBATCH --time=72:00:00
#SBATCH --array=0-1%2
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=12G
#SBATCH --cpus-per-task=5
#SBATCH --image=argrosso/htstools:0.2.1
#SBATCH --chdir=$HOME

export chdir=$(realpath ~/scratch/S6)
export s6_sort_ind_bam=$(realpath ~/scratch/S4)
export s6_remove_mt=$(realpath ~/scratch/S6)
export removechrompy=$(realpath ~/nfs/scripts)

ls $s6_sort_ind_bam/sorted*.bam | awk -F'[/sorted_/.]' '{print $(NF-1)}' > $s6_sort_ind_bam/list_bam.txt
bam_samples=($(cat $s6_sort_ind_bam/list_bam.txt))

echo "Removing mMT in BAM files with sample ${bam_samples[${SLURM_ARRAY_TASK_ID}]}"

for bam_samples in $bam_samples;
do srun shifter samtools view -h -@ $SLURM_CPUS_PER_TASK $s6_sort_ind_bam/sorted_${bam_samples[${SLURM_ARRAY_TASK_ID}]}.bam | \
python $removechrompy/removeChrom.py - - chrM | \
shifter samtools view -b -h - > $s6_remove_mt/${bam_samples[${SLURM_ARRAY_TASK_ID}]}nMT.bam;
done ;

srun shifter samtools sort -@ $SLURM_CPUS_PER_TASK -o $s6_sort_ind_bam/${bam_samples[${SLURM_ARRAY_TASK_ID}]}.bam \
$s6_remove_mt/${bam_samples[${SLURM_ARRAY_TASK_ID}]}nMT.bam;

srun shifter samtools index -b -@ $SLURM_CPUS_PER_TASK $s6_sort_ind_bam/${bam_samples[${SLURM_ARRAY_TASK_ID}]}.bam

echo "Statistics for job $SLURM_JOB_ID:"
sacct --format="JOBID,Start,End,Elapsed,CPUTime,AveDiskRead,AveDiskWrite,MaxRSS,exitcode,derivedexitcode" -j $SLURM_JOB_ID

rm -rf `ls -la /tmp/ | grep 'aesousa' | awk ' { print $9 } '`
