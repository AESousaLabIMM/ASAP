#!/bin/bash
#SBATCH --job-name=S10
#SBATCH --time=72:00:00
#SBATCH --array=0-1%2
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=12G
#SBATCH --cpus-per-task=8
#SBATCH --chdir=$HOME
#conv de bed para bedpe

export S9fix=$(realpath ~/scratch/S9/fix)
mkdir -p $(realpath ~/scratch/S10)
ls $(realpath ~/scratch)
mkdir -p $(realpath ~/scratch/S10/ss1)
mkdir -p $(realpath ~/scratch/S10/ss2)
export S10_1=$(realpath ~/scratch/S10/ss1)
export S10_2=$(realpath ~/scratch/S10/ss2)

ls $S9fix/*.bam | awk -F'[/.]' '{print $(NF-1)}' > $S9fix/list_bam.txt
bam_samples=($(cat $S9fix/list_bam.txt))

echo "Converting BAM to BEDPE with sample ${bam_samples[${SLURM_ARRAY_TASK_ID}]}"

for bam_samples in $bam_samples;
do
srun shifter --image=argrosso/htstools:0.2.1 samtools view -bf 0x2 -@ $SLURM_CPUS_PER_TASK -o $S10_1/${bam_samples[${SLURM_ARRAY_TASK_ID}]}_tmp.bam \
$S9fix/${bam_samples[${SLURM_ARRAY_TASK_ID}]}.bam;
srun shifter --image=argrosso/htstools:0.2.1 bedtools bamtobed -bedpe -i $S10_1/${bam_samples[${SLURM_ARRAY_TASK_ID}]}_tmp.bam > $S10_2/${bam_samples[${SLURM_ARRAY_TASK_ID}]}_tmp.bedpe;
done;

echo "Statistics for job $SLURM_JOB_ID:"
sacct --format="JOBID,Start,End,Elapsed,CPUTime,AveDiskRead,AveDiskWrite,MaxRSS,exitcode,derivedexitcode" -j $SLURM_JOB_ID

rm -rf `ls -la /tmp/ | grep 'aesousa' | awk ' { print $9 } '`
