#!/bin/bash

#BATCH --job-name=taslp18_taslp18_flute_time_14_gammatone
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:30:00
#SBATCH --mem=32GB
#SBATCH --output=../slurm/slurm_taslp18_taslp18_flute_time_14_gammatone_%j.out

module purge
module load/matlab2017a

matlab -nosplash -nodesktop -nodisplay -r "audio_name = 'taslp18_flute'; modulations_str = 'time'; J = 14; wavelet_str = 'gammatone'; run('../taslp18_reconstructions.m');"