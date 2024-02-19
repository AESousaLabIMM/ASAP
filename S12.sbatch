#!/bin/bash
#SBATCH --job-name=S12
#SBATCH --time=72:00:00
#SBATCH --array=0-1%2
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=12G
#SBATCH --cpus-per-task=8
#SBATCH --chdir=$HOME
#formatação do bedpe para o MACS (passo seguinte)
mkdir -p $(realpath ~/scratch/S12)
export script=$(realpath ~/nfs/scripts)
export S12=$(realpath ~/scratch/S12)
export S11=$(realpath ~/scratch/S11)

ls $S11/*.bedpe | awk -F'[/.]' '{print $(NF-1)}' > $S11/list_bedpe.txt
bedpe_samples=($(cat $S11/list_bedpe.txt))

echo "Adapting BEDPE for MACS2 calling with sample ${bedpe_samples[${SLURM_ARRAY_TASK_ID}]}"

for bedpe_samples in $bedpe_samples;
do
srun $script/bedpeMinimalConvert.sh $S11/${bedpe_samples[${SLURM_ARRAY_TASK_ID}]}.bedpe > $S12/${bedpe_samples[${SLURM_ARRAY_TASK_ID}]}_macs2.bedpe;
done;

echo "Statistics for job $SLURM_JOB_ID:"
sacct --format="JOBID,Start,End,Elapsed,CPUTime,AveDiskRead,AveDiskWrite,MaxRSS,exitcode,derivedexitcode" -j $SLURM_JOB_ID

rm -rf `ls -la /tmp/ | grep 'aesousa' | awk ' { print $9 } '`
