# This shell script executes the Slurm jobs for computing reconstructions.

sbatch tsp19_name=speech_sc=none_J=16_wav=gammatone.sbatch
sbatch tsp19_name=speech_sc=none_J=16_wav=morlet.sbatch
sbatch tsp19_name=speech_sc=time_J=16_wav=gammatone.sbatch
sbatch tsp19_name=speech_sc=time_J=16_wav=morlet.sbatch
sbatch tsp19_name=speech_sc=time-frequency_J=16_wav=gammatone.sbatch
sbatch tsp19_name=speech_sc=time-frequency_J=16_wav=morlet.sbatch
