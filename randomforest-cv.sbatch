#!/bin/bash
##
## example-array.slurm.sh: submit an array of jobs with a varying parameter
##
## Lines starting with #SBATCH are read by Slurm. Lines starting with ## are comments.
## All other lines are read by the shell.
##
#SBATCH --account=priority-briansmithers        #specify the account to use
#SBATCH --job-name=rf            # job name
#SBATCH --partition=priority              # queue partition to run the job in
#SBATCH --nodes=1                       # number of nodes to allocate
#SBATCH --ntasks-per-node=1             # number of descrete tasks - keep at one except for MPI
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=128              # number of cores to allocate
#SBATCH --mem=256G                     # 2000 MB of Memory allocated; set --mem with care
#SBATCH --time=1-00:00:00                 # Maximum job run time
#SBATCH --mail-user=shuysman@gmail.com
#SBATCH --mail-type=ALL
#SBATCH --output=rfcv-%j.out
#SBATCH --error=rfcv-%j.err

date
hostname -s
module load Mamba
source $HOME/.bashrc
mamba activate conus-cover
Rscript randomforest-cv.R
date