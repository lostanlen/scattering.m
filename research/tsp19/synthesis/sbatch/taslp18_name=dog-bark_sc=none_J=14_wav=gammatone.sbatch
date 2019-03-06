#!/bin/bash

#BATCH --job-name=tsp19_name=dog-bark_sc=none_J=14_wav=gammatone
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:30:00
#SBATCH --mem=8GB
#SBATCH --output=../slurm/slurm_tsp19_name=dog-bark_sc=none_J=14_wav=gammatone_%j.out

module purge
module load matlab/2017a

matlab -nosplash -nodesktop -nodisplay -r "audio_name_str = 'dog-bark'; modulations_str = 'none'; J = 14; wavelet_str = 'gammatone'; addpath(genpath('~/scattering.m')); addpath(genpath('~/export_fig')); run('../tsp19_reconstructions.m');"