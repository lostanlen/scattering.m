#!/bin/bash

#BATCH --job-name=taslp18_taslp18_flute_none_11_morlet
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:30:00
#SBATCH --mem=32GB
#SBATCH --output=../slurm/slurm_taslp18_taslp18_flute_none_11_morlet_%j.out

module purge
module load/matlab2017a

matlab -nosplash -nodesktop -nodisplay -r "audio_name = taslp18_flute; modulations_str = none; J = 11; wavelet_str = morlet; run('../taslp18_reconstructions.m');"