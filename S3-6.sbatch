#!/bin/bash
#SBATCH --job-name=S3-6
#SBATCH --time=72:00:00
#SBATCH --mem-per-cpu=12G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --chdir=$HOME

export scripts=$(realpath ~/nfs/scripts)

sbatch --wait $scripts/S2.sbatch

sbatch --wait $scripts/S3.sbatch

sbatch --wait $scripts/S4.sbatch

sbatch --wait $scripts/S5.sbatch

sbatch $scripts/S6.sbatch
