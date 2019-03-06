#!/bin/bash

#BATCH --job-name=tsp19_name=flute_sc=time-frequency_J=15_wav=morlet
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:30:00
#SBATCH --mem=8GB
#SBATCH --output=../slurm/slurm_tsp19_name=flute_sc=time-frequency_J=15_wav=morlet_%j.out

module purge
module load matlab/2017a

matlab -nosplash -nodesktop -nodisplay -r "audio_name_str = 'flute'; modulations_str = 'time-frequency'; J = 15; wavelet_str = 'morlet'; addpath(genpath('~/scattering.m')); addpath(genpath('~/export_fig')); run('../tsp19_reconstructions.m');"