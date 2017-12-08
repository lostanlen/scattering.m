#!/bin/bash

#BATCH --job-name=taslp18_name=dog-bark_mcdermott
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=48:00:00
#SBATCH --mem=8GB
#SBATCH --output=../slurm/slurm_taslp18_name=dog-bark_mcdermott_%j.out

module purge
module load matlab/2017a

matlab -nosplash -nodesktop -nodisplay -r "audio_name_str = 'dog-bark'; addpath(genpath('~/Sound_Texture_Synthesis_Toolbox/')); run('../taslp18_mcdermott.m');"
