#!/bin/bash

#BATCH --job-name=taslp18_name=dog-bark_sc=time_J=11_wav=morlet
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:30:00
#SBATCH --mem=8GB
#SBATCH --output=../slurm/slurm_taslp18_name=dog-bark_sc=time_J=11_wav=morlet_%j.out

module purge
module load/matlab2017a

matlab -nosplash -nodesktop -nodisplay -r "audio_name = 'taslp18_dog-bark'; modulations_str = 'time'; J = 11; wavelet_str = 'morlet'; addpath('~/scattering.m'); addpath('~/export_fig'); run('../taslp18_reconstructions.m');"