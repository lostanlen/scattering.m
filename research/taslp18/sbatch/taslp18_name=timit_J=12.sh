# This shell script executes the Slurm jobs for computing reconstructions.

sbatch taslp18_name=timit_sc=none_J=12_wav=gammatone.sbatch
sbatch taslp18_name=timit_sc=none_J=12_wav=morlet.sbatch
sbatch taslp18_name=timit_sc=time_J=12_wav=gammatone.sbatch
sbatch taslp18_name=timit_sc=time_J=12_wav=morlet.sbatch
sbatch taslp18_name=timit_sc=time-frequency_J=12_wav=gammatone.sbatch
sbatch taslp18_name=timit_sc=time-frequency_J=12_wav=morlet.sbatch
