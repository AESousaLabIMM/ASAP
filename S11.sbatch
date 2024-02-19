#!/bin/bash
#SBATCH --job-name=S11
#SBATCH --time=72:00:00
#SBATCH --array=0-1%2
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=12G
#SBATCH --cpus-per-task=8
#SBATCH --chdir=$HOME
#remoção do shift do tn5
mkdir -p $(realpath ~/scratch/S11)
export script=$(realpath ~/nfs/scripts)
export S10_2=$(realpath ~/scratch/S10/ss2)
export S11=$(realpath ~/scratch/S11)
chmod u+x bedpeTn5shift.sh
ls $S10_2/*.bedpe | awk -F'[/.]' '{print $(NF-1)}' > $S10_2/list_bedpe.txt
bedpe_samples=($(cat $S10_2/list_bedpe.txt))

echo "Converting BAM to BEDPE with sample ${bedpe_samples[${SLURM_ARRAY_TASK_ID}]}"

for bedpe_samples in $bedpe_samples;
do
srun $script/bedpeTn5shift.sh $S10_2/${bedpe_samples[${SLURM_ARRAY_TASK_ID}]}.bedpe > $S11/${bedpe_samples[${SLURM_ARRAY_TASK_ID}]}_tn5.bedpe;
done;

echo "Statistics for job $SLURM_JOB_ID:"
sacct --format="JOBID,Start,End,Elapsed,CPUTime,AveDiskRead,AveDiskWrite,MaxRSS,exitcode,derivedexitcode" -j $SLURM_JOB_ID

rm -rf `ls -la /tmp/ | grep 'aesousa' | awk ' { print $9 } '`
