#!/bin/bash
#SBATCH --job-name=S7
#SBATCH --time=72:00:00
#SBATCH --array=0-1%2
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=8G
#SBATCH --cpus-per-task=16
#SBATCH --image=argrosso/htstools:0.2.1
#SBATCH --chdir=$HOME
mkdir -p $(realpath ~/scratch/S7)
mkdir -p $(realpath ~/scratch/S7/S7f)
export S6_BAM=$(realpath ~/scratch/S6)
export S7=$(realpath ~/scratch/S7)
export S7f=$(realpath ~/scratch/S7/S7f)

ls $S6_BAM/*.bam | awk -F'[/.]' '{print $(NF-1)}' > $S6_BAM/list_bam.txt
bam_samples=($(cat $S6_BAM/list_bam.txt))

echo "Properly pairing BAM files with sample ${bam_samples[${SLURM_ARRAY_TASK_ID}]}"

for bam_samples in $bam_samples;
do srun shifter samtools view -bh -f 3 -@ $SLURM_CPUS_PER_TASK $S6_BAM/${bam_samples[${SLURM_ARRAY_TASK_ID}]}.bam > $S7/${bam_samples[${SLURM_ARRAY_TASK_ID}]}_pp.bam
done ;
wait ;

for bam_samples in $bam_samples;
do srun shifter samtools sort -@ $SLURM_CPUS_PER_TASK -o $S7f/${bam_samples[${SLURM_ARRAY_TASK_ID}]}_pp.bam \
$S7/${bam_samples[${SLURM_ARRAY_TASK_ID}]}_pp.bam;
srun shifter samtools index -b -@ $SLURM_CPUS_PER_TASK $S7f/${bam_samples[${SLURM_ARRAY_TASK_ID}]}_pp.bam;
done;


echo "Statistics for job $SLURM_JOB_ID:"
sacct --format="JOBID,Start,End,Elapsed,CPUTime,AveDiskRead,AveDiskWrite,MaxRSS,exitcode,derivedexitcode" -j $SLURM_JOB_ID

rm -rf `ls -la /tmp/ | grep 'aesousa' | awk ' { print $9 } '`
