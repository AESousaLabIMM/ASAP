#!/bin/bash
#SBATCH --job-name=S9
#SBATCH --time=72:00:00
#SBATCH --array=0-1%2
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=12G
#SBATCH --cpus-per-task=8
#SBATCH --chdir=$HOME
#correção do alinhamento das origens de sequenciação nos ficheiros BAM
mkdir -p $(realpath ~/scratch/S9)
mkdir -p $(realpath ~/scratch/S9/names)
mkdir -p $(realpath ~/scratch/S9/fix)
export S8=$(realpath ~/scratch/S8)
export S9names=$(realpath ~/scratch/S9/names)
export S9fix=$(realpath ~/scratch/S9/fix)

ls $S8/*.bam | awk -F'[/.]' '{print $(NF-1)}' > $S8/list_bam.txt
bam_samples=($(cat $S8/list_bam.txt))

echo "Fix mates BAM files with sample ${bam_samples[${SLURM_ARRAY_TASK_ID}]}"

for bam_samples in $bam_samples;
do
srun shifter --image=argrosso/htstools:0.2.1 samtools sort -n -@ $SLURM_CPUS_PER_TASK -o $S9names/${bam_samples[${SLURM_ARRAY_TASK_ID}]}_names.bam \
$S8/${bam_samples[${SLURM_ARRAY_TASK_ID}]}.bam;
srun shifter --image=argrosso/htstools:0.2.1 samtools fixmate -@ $SLURM_CPUS_PER_TASK $S9names/${bam_samples[${SLURM_ARRAY_TASK_ID}]}_names.bam $S9fix/${bam_samples[${SLURM_ARRAY_TASK_ID}]}_fix.bam;
done;

echo "Statistics for job $SLURM_JOB_ID:"
sacct --format="JOBID,Start,End,Elapsed,CPUTime,AveDiskRead,AveDiskWrite,MaxRSS,exitcode,derivedexitcode" -j $SLURM_JOB_ID

rm -rf `ls -la /tmp/ | grep 'aesousa' | awk ' { print $9 } '`
