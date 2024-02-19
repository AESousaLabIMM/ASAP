#!/bin/bash
#SBATCH --job-name=S1
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --nodes=1
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=4
#SBATCH --chdir=$HOME

mkdir -p $(realpath ~/scratch/S1)
mkdir -p $(realpath ~/nfs/S1)
mkdir -p $(realpath ~/nfs/raw)
export fq_files=$(realpath ~/nfs/raw)
export workdir=$(realpath ~/scratch/S1)
export output=$(realpath ~/nfs/S1)
export tempdir=$(realpath ~/scratch/S1)

export srun="srun --nodes=1 --ntasks=1 --cpus-per-task=$SLURM_CPUS_PER_TASK"

#parallel="parallel --dry-run --delay 0.2 -j $SLURM_NTASKS --joblog $workdir/$SLURM_JOB_ID.log --tempdir $tempdir"
parallel="parallel --delay 0.2 -j $SLURM_NTASKS --joblog $workdir/$SLURM_JOB_ID.log --tempdir $tempdir"

#Outputs list of all .fq.gz files to a txt files named list_sam
ls $fq_files/T*/*.fq.gz | awk -F'[/.]' '{print $(NF-2)}' > $fq_files/list_fq.txt

cat $fq_files/list_fq.txt

cat $fq_files/list_fq.txt | $parallel "$srun shifter -v --image=argrosso/htspreprocessing:0.1.2 fastqc -t $SLURM_CPUS_PER_TASK $fq_files/T*/{}.fq.gz -o $output"

echo "Statistics for job $SLURM_JOB_ID"
sacct --format="JOBID,Start,End,Elapsed,AllocCPUs,CPUTime,AveDiskRead,AveDiskWrite,MaxRSS,MaxVMSize,exitcode,derivedexitcode" -j $SLURM_JOB_ID
