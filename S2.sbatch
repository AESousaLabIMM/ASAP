#!/bin/bash
#SBATCH --job-name=bowtie2
#SBATCH --time=72:00:00
#SBATCH --mem-per-cpu=16G
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=4
#SBATCH --image=docker:ummidock/bowtie2:latest
#SBATCH --chdir=$HOME
mkdir $(realpath ~/scratch/S2)
mkdir $(realpath ~/nfs/S2)
mkdir -p $(realpath ~/nfs/raw)
LANG="" # tries to avoid Perl warnings

export SEQUENCES=$(realpath ~/nfs/raw)
export GENOME=/mnt/nfs/lobo/IMM-NFS/genomes/hg38/Sequence/Bowtie2Index/genome

export chdir=$(realpath ~/scratch/S2)

parallel="parallel --delay 0.2 -j $SLURM_NTASKS --joblog $chdir/$SLURM_JOB_ID.log"
#parallel="parallel --dry-run --delay 0.2 -j $SLURM_NTASKS --joblog /mnt/beegfs/scratch/PRECISE/alexandre.raposo/Tcell_dev_ATAC/BAMinprogress/$SLURM_JOB_ID.log"

#ls -d $SEQUENCES/T*/ | $parallel 'srun shifter bowtie2 -x $GENOME -p $SLURM_CPUS_PER_TASK -1\
# {}*R1*.fq.gz -2 {}*R2*.fq.gz -S $chdir/$(basename {}).sam'

ls -d $SEQUENCES/ | $parallel 'srun shifter bowtie2 -x $GENOME -p $SLURM_CPUS_PER_TASK -1\
 {}R1.fq -2 {}R2.fq -S $chdir/$(basename {}).sam'

echo "Statistics for job $SLURM_JOB_ID:"
sacct --format="JOBID,Start,End,Elapsed,CPUTime,AveDiskRead,AveDiskWrite,MaxRSS,MaxVMSize,exitcode,derivedexitcode" -j $SLURM_JOB_ID

rm -rf `ls -la /tmp/ | grep 'aesousa' | awk ' { print $9 } '`
