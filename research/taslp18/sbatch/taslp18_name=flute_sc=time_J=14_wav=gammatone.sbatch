#!/bin/bash

#BATCH --job-name=taslp18_name=flute_sc=time_J=14_wav=gammatone
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:30:00
#SBATCH --mem=8GB
#SBATCH --output=../slurm/slurm_taslp18_name=flute_sc=time_J=14_wav=gammatone_%j.out

module purge
module load/matlab2017a

matlab -nosplash -nodesktop -nodisplay -r "audio_name = 'taslp18_flute'; modulations_str = 'time'; J = 14; wavelet_str = 'gammatone'; addpath('~/scattering.m'); addpath('~/export_fig'); run('../taslp18_reconstructions.m');"