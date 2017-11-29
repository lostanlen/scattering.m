#!/bin/bash

#BATCH --job-name=taslp18_name=speech_sc=time-frequency_J=14_wav=gammatone
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:30:00
#SBATCH --mem=8GB
#SBATCH --output=../slurm/slurm_taslp18_name=speech_sc=time-frequency_J=14_wav=gammatone_%j.out

module purge
module load matlab/2017a

matlab -nosplash -nodesktop -nodisplay -r "audio_name_str = 'speech'; modulations_str = 'time-frequency'; J = 14; wavelet_str = 'gammatone'; addpath(genpath('~/scattering.m')); addpath(genpath('~/export_fig')); run('../taslp18_reconstructions.m');"