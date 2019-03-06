# This shell script executes the Slurm jobs for computing reconstructions.

sbatch tsp19_name=speech_sc=none_J=11_wav=gammatone.sbatch
sbatch tsp19_name=speech_sc=none_J=11_wav=morlet.sbatch
sbatch tsp19_name=speech_sc=time_J=11_wav=gammatone.sbatch
sbatch tsp19_name=speech_sc=time_J=11_wav=morlet.sbatch
sbatch tsp19_name=speech_sc=time-frequency_J=11_wav=gammatone.sbatch
sbatch tsp19_name=speech_sc=time-frequency_J=11_wav=morlet.sbatch
