#!/bin/bash
#SBATCH --job-name=S3
#SBATCH --time=72:00:00
#SBATCH --mem-per-cpu=6G
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=5
#SBATCH --chdir=$HOME

export SAM=$(realpath ~/scratch/S2)
export chdir=$(realpath ~/scratch/S3)

export srun="srun --nodes=1 --ntasks=1 --cpus-per-task=$SLURM_CPUS_PER_TASK"
parallel="parallel --delay 0.2 -j $SLURM_NTASKS --joblog $chdir/$SLURM_JOB_ID.log"
#parallel="parallel --dry-run --delay 0.2 -j $SLURM_NTASKS --joblog $chdir/$SLURM_JOB_ID.log"
echo "A fazer samtools view"
# sam2bam, sort bam, index bam
ls $SAM/*.sam | $parallel '

$srun shifter --image=docker:argrosso/htstools:0.2.1 samtools view -S -b -@ $SLURM_CPUS_PER_TASK {} > $chdir/$(basename {} | cut -f 1 -d '.').bam'

cp $chdir/*.bam $(realpath ~/nfs/S3)
rm -v $(realpath ~/scratch/S2)/*.sam

echo "Statistics for job $SLURM_JOB_ID:"
sacct --format="JOBID,Start,End,Elapsed,CPUTime,AveDiskRead,AveDiskWrite,MaxRSS,MaxVMSize,exitcode,derivedexitcode" -j $SLURM_JOB_ID

#limpar o tmp
rm -rf `ls -la /tmp/ | grep 'aesousa' | awk ' { print $9 } '`
