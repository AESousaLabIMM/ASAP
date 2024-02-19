#!/bin/bash
#SBATCH --job-name=S8
#SBATCH --time=72:00:00
#SBATCH --array=0-1%2
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=4G
#SBATCH --cpus-per-task=8
#SBATCH --chdir=$HOME
#remoção de leituras duplicadas

mkdir -p $(realpath ~/scratch/S8)
export workdir=$(realpath ~/scratch/S8)
export S7f=$(realpath ~/scratch/S7/S7f)
export S8=$(realpath ~/scratch/S8)


ls $S7f/*.bam | awk -F'[/.]' '{print $(NF-1)}' > $S7f/list_bam.txt
bam_samples=($(cat $S7f/list_bam.txt))

echo "Remove duplicates BAM files with sample ${bam_samples[${SLURM_ARRAY_TASK_ID}]}"

for bam_samples in $bam_samples;
do srun shifter --image=broadinstitute/gatk:latest gatk --java-options '-Xmx32G' MarkDuplicates --INPUT $S7f/${bam_samples[${SLURM_ARRAY_TASK_ID}]}.bam \
--OUTPUT $S8/${bam_samples[${SLURM_ARRAY_TASK_ID}]}_rmdup.bam --TMP_DIR $workdir/ --METRICS_FILE $workdir/${bam_samples[${SLURM_ARRAY_TASK_ID}]}_metricsDups.txt \
--REMOVE_DUPLICATES true
done ;
wait ;

for bam_samples in $bam_samples;
do srun shifter --image=argrosso/htstools:0.2.1 samtools sort -@ $SLURM_CPUS_PER_TASK -o $S8/${bam_samples[${SLURM_ARRAY_TASK_ID}]}_rmdup.bam \
$S8/${bam_samples[${SLURM_ARRAY_TASK_ID}]}_rmdup.bam;
srun shifter --image=argrosso/htstools:0.2.1 samtools index -b -@ $SLURM_CPUS_PER_TASK $S8/${bam_samples[${SLURM_ARRAY_TASK_ID}]}_rmdup.bam;
done;

echo "Statistics for job $SLURM_JOB_ID:"
sacct --format="JOBID,Start,End,Elapsed,CPUTime,AveDiskRead,AveDiskWrite,MaxRSS,exitcode,derivedexitcode" -j $SLURM_JOB_ID

rm -rf `ls -la /tmp/ | grep 'aesousa' | awk ' { print $9 } '`
