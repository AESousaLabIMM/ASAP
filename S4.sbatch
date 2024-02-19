#!/bin/bash
#SBATCH --job-name=S4
#SBATCH --time=72:00:00
#SBATCH --mem-per-cpu=10G
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=6
#SBATCH --chdir=$HOME

export BAM=$(realpath ~/scratch/S3)
export chdir=$(realpath ~/scratch/S4)
mkdir /mnt/beegfs/scratch/AESOUSA/aesousa/tmp
mkdir /mnt/beegfs/scratch/AESOUSA/aesousa/tmp/$SLURM_JOB_ID
export workdir=/mnt/beegfs/scratch/AESOUSA/aesousa/tmp/$SLURM_JOB_ID
export srun="srun --nodes=1 --ntasks=1 --cpus-per-task=$SLURM_CPUS_PER_TASK"
export parallel="parallel --delay 0.2 -j $SLURM_NTASKS --joblog $chdir/$SLURM_JOB_ID.log"
#parallel="parallel --dry-run --delay 0.2 -j $SLURM_NTASKS --joblog $chdir/$SLURM_JOB_ID.log"
echo "A fazer samtools sort"
ls $BAM/*.bam | $parallel '

$srun shifter --image=docker:argrosso/htstools:0.2.1 samtools sort -@ $SLURM_CPUS_PER_TASK -o $workdir/sorted_$(basename {}) $BAM/$(basename {})'

mv $workdir/sorted_*.bam $chdir

echo "Statistics for job $SLURM_JOB_ID:"
sacct --format="JOBID,Start,End,Elapsed,CPUTime,AveDiskRead,AveDiskWrite,MaxRSS,MaxVMSize,exitcode,derivedexitcode" -j $SLURM_JOB_ID

rm -rf `ls -la /tmp/ | grep 'aesousa' | awk ' { print $9 } '`
rm -r $(realpath $workdir)
