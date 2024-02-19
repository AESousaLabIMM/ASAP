#!/bin/bash
#SBATCH --job-name=S13
#SBATCH --time=72:00:00
#SBATCH --array=0-1%2
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=12G
#SBATCH --cpus-per-task=8
#SBATCH --chdir=$HOME
mkdir -p $(realpath ~/scratch/S13)
export S12=$(realpath ~/scratch/S12)
export S13=$(realpath ~/scratch/S13)

ls $S12/*.bedpe | awk -F'[/.]' '{print $(NF-1)}' > $S12/list_bedpe.txt
bedpe_samples=($(cat $S12/list_bedpe.txt))

echo "Adapting BEDPE for MACS2 calling with sample ${bedpe_samples[${SLURM_ARRAY_TASK_ID}]}"

for bedpe_samples in $bedpe_samples;
do
srun shifter --image=argrosso/htstools:0.2.1 macs2 callpeak -t $S12/${bedpe_samples[${SLURM_ARRAY_TASK_ID}]}.bedpe \
-f BEDPE -g hs --keep-dup 1 \
--nomodel -q 0.05 --extsize 200 --shift -100 \
-n ${bedpe_samples[${SLURM_ARRAY_TASK_ID}]} -B \
--outdir $S13
done;

echo "Statistics for job $SLURM_JOB_ID:"
sacct --format="JOBID,Start,End,Elapsed,CPUTime,AveDiskRead,AveDiskWrite,MaxRSS,exitcode,derivedexitcode" -j $SLURM_JOB_ID

rm -rf `ls -la /tmp/ | grep 'aesousa' | awk ' { print $9 } '`
