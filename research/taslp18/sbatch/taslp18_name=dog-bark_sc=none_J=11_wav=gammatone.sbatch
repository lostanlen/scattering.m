#!/bin/bash

#BATCH --job-name=taslp18_name=dog-bark_sc=none_J=11_wav=gammatone
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:30:00
#SBATCH --mem=8GB
#SBATCH --output=../slurm/slurm_taslp18_name=dog-bark_sc=none_J=11_wav=gammatone_%j.out

module purge
module load matlab2017a

matlab -nosplash -nodesktop -nodisplay -r "audio_name_str = 'taslp18_dog-bark'; modulations_str = 'none'; J = 11; wavelet_str = 'gammatone'; addpath(genpath('~/scattering.m')); addpath(genpath('~/export_fig')); run('../taslp18_reconstructions.m');"