# ASAP: ATAC-Seq Automated Pipeline
## Purpose

This pipeline was developed in order to automate the steps of a typical ATAC-seq processing, instead of waiting for each step to finish running to start the next one.

## Presumptions

This automation was developed for iMM-LOBO HPC, which uses Slurm as a Workload Manager and Shifter as a Environment Container System.

### Environment Settings

#### Storage

In IMM-LOBO HPC, there is two types of storage: the Long-Term Storage (NFS) which is run by HDDs with higher capacity and Short-Term (or Working) Storage (scratch) which is run by SSDs with lower capacity, to enable the HPC to work at faster I/O speeds while not spending thousands on hardware.

#### Node Settings

This HPC has various nodes to deploy the jobs, and the nodes are divided by Regular Performance Nodes and Higher performance Nodes.

> **For more info on the specifications of this HPC, visit its [ReadTheDocs
> page](https://imm.medicina.ulisboa.pt/cluster/quickstart/lobo.html)**

## Modules

This ATAC-seq processing procedure is composed of 14 steps:

| Step Nr. | Description                  |
|:--------:|:----------------------------:|
| S1       | FastQC                       |
| S2       | Alignment                    |
| S3       | SAM to BAM                   |
| S4       | Sorting                      |
| S5       | Indexing                     |
| S6       | Remove mDNA                  |
| S7       | Pairing                      |
| S8       | Remove Duplicates            |
| S9       | Fix Mates                    |
| S10      | BAM to BEDPE                 |
| S11      | Remove Tn5                   |
| S12      | BEDPE "Minimal   Conversion" |
| S13      | MACS2                        |
| S14      | Peak Quantification          |
| S15      | BAM files merging            |

### Step File Structure

The **header** of the sbatch files provide instructions on how the job should be run by Slurm:

<u>Serial Job mode</u> (each job only run after the one behind is finished)

```shell
#!/bin/bash
#SBATCH --job-name=<name of the job>
#SBATCH --time=<time limit to finish the job>
#SBATCH --array=<format of the array - 1st_task-last_tast%number_of_parallel_tasks>
#SBATCH --mem-per-cpu=<RAM memory usage reservation>
#SBATCH --nodes=<number of nodes>
#SBATCH --ntasks=<tasks to run>
#SBATCH --cpus-per-task=<number of CPUs per task>
#SBATCH --chdir=<directory to save Slurm logs>
```

<u>Parallel Job mode</u> (all jobs run at the same time)

```shell
#!/bin/bash
#SBATCH --job-name=<name of the job>
#SBATCH --time=<time limit to finish the job>
#SBATCH --mem-per-cpu=<RAM memory usage reservation>
#SBATCH --nodes=<number of nodes>
#SBATCH --ntasks=<tasks to run>
#SBATCH --cpus-per-task=<number of CPUs per task>
#SBATCH --chdir=<directory to save Slurm logs>
```

### Automation

ASAP has 2 levels of automation: step automation and directory automation.

#### Step Automation

For step automation, ASAP uses a simple `sbatch` that will deploy all the desired steps after each one is completed.

The header type is parallel and has the following structure (example for automating the steps 3 to 6):

```shell
#!/bin/bash
#SBATCH --job-name=S3-6
#SBATCH --time=72:00:00
#SBATCH --mem-per-cpu=12G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --chdir=$HOME/results

export scripts=$(realpath ~/nfs/scripts)

sbatch --wait $scripts/S2.sbatch

sbatch --wait $scripts/S3.sbatch

sbatch --wait $scripts/S4.sbatch

sbatch --wait $scripts/S5.sbatch

sbatch $scripts/S6.sbatch
```

`$scripts` var is the directory of all the step (sbatch) files and `sbatch --wait <sbatch step file>` performs the `sbatch step file`. The last step file executed won't need the `--wait` parameter and its command will be `sbatch <sbatch step file>`.



> **Warning:** Slurm doesn't understand if you're referring to your home directory by typing `~`, realpath is used as a relative path parser as a workaround (but won't work in Slurm headers)



> `~/nfs` is a custom shortcut created in the home dir for the current user's folder in Long-Term Storage, you can create it with the shell command 
> 
> `ln -s <target dir/file> <link_dir/name of the link>`



##### Job Automation Files Creation

There is two ways of creating the mentioned automated job file: directory (dir) and step automation.

The example above show how to perform step automation, but this requires that in all job files the dirs are already defined. Dir automation is more difficult to implement due to relative path limitations of Slurm (read above), but is completely doable by a shell or Python script (remember that HPCs only run basic python commands and libraries on interactive mode, so it would be preferable to use shell scripts, unless you want to run a python container specifically for dir automation).

**The current version of ASAP does not support dir automation**, so you will have to code a custom script as mention above or set all directories on all job files manually (you just need to do this once per user).

##### Starting Menu

For convenience, it was coded a small "launcher"  for this tool, written in python, with the filename `setup.py` that only will run a single selected step from a menu and then execute `squeue`.
