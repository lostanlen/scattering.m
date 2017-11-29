# This shell script executes the Slurm jobs for computing reconstructions.

sbatch taslp18_name=speech_sc=none_J=13_wav=gammatone.sbatch
sbatch taslp18_name=speech_sc=none_J=13_wav=morlet.sbatch
sbatch taslp18_name=speech_sc=time_J=13_wav=gammatone.sbatch
sbatch taslp18_name=speech_sc=time_J=13_wav=morlet.sbatch
sbatch taslp18_name=speech_sc=time-frequency_J=13_wav=gammatone.sbatch
sbatch taslp18_name=speech_sc=time-frequency_J=13_wav=morlet.sbatch
