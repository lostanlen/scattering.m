#!/bin/bash

#BATCH --job-name=taslp18_taslp18_dog-bark_time-frequency_14_morlet
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:30:00
#SBATCH --mem=32GB
#SBATCH --output=../slurm/slurm_taslp18_taslp18_dog-bark_time-frequency_14_morlet_%j.out

module purge
module load/matlab2017a

matlab -nosplash -nodesktop -nodisplay -r "audio_name = 'taslp18_dog-bark'; modulations_str = 'time-frequency'; J = 14; wavelet_str = 'morlet'; run('../taslp18_reconstructions.m');"