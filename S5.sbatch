#!/bin/bash
#SBATCH --job-name=S5
#SBATCH --time=72:00:00
#SBATCH --mem-per-cpu=12G
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=5
#SBATCH --chdir=$HOME

export chdir=$(realpath ~/nfs/S5)
export SORTED=$(realpath ~/scratch/S4)
export srun="srun --nodes=1 --ntasks=1 --cpus-per-task=$SLURM_CPUS_PER_TASK"
parallel="parallel --delay 0.2 -j $SLURM_NTASKS --joblog $chdir/$SLURM_JOB_ID.log"
#parallel="parallel --dry-run --delay 0.2 -j $SLURM_NTASKS --joblog $chdir/$SLURM_JOB_ID.log"
echo "A fazer samtools index"
# index bam

ls $SORTED/sorted*.bam | $parallel '

$srun shifter --image=docker:argrosso/htstools:0.2.1 samtools index -@ $SLURM_CPUS_PER_TASK {}'

#mv $SORTED/*.bai $chdir

echo "Statistics for job $SLURM_JOB_ID:"
sacct --format="JOBID,Start,End,Elapsed,CPUTime,AveDiskRead,AveDiskWrite,MaxRSS,MaxVMSize,exitcode,derivedexitcode" -j $SLURM_JOB_ID

rm -rf `ls -la /tmp/ | grep 'aesousa' | awk ' { print $9 } '`
