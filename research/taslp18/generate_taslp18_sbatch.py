import os
import sys


audio_names = ['dog-bark', 'flute'];
modulations_strs = ['none', 'time', 'time-frequency'];
wavelet_strs = ['morlet', 'gammatone'];
Js = [11, 14, 17];


os.makedirs("sbatch", exist_ok=True)
os.makedirs("slurm", exist_ok=True)

# Loop over recording units.
for audio_name_str in audio_names:

    # Loop over modulations.
    for modulations_str in modulations_strs:

        # Loop over Js.
        for J in Js:

            J_str = str(J)

            # Loop over wavelets.
            for wavelet_str in wavelet_strs:

                # Define file path.
                job_name = "_".join([
                    "taslp18",
                    "name=" + audio_name_str,
                    "sc=" + modulations_str,
                    "J=" + J_str,
                    "wav=" + wavelet_str
                ])
                file_name = job_name + ".sbatch"
                file_path = os.path.join("sbatch", file_name)


                # Open file.
                with open(file_path, "w") as f:
                    f.write("#!/bin/bash\n")
                    f.write("\n")
                    f.write("#BATCH --job-name=" + job_name + "\n")
                    f.write("#SBATCH --nodes=1\n")
                    f.write("#SBATCH --tasks-per-node=1\n")
                    f.write("#SBATCH --cpus-per-task=1\n")
                    f.write("#SBATCH --time=0:30:00\n")
                    f.write("#SBATCH --mem=8GB\n")
                    f.write("#SBATCH --output=../slurm/slurm_" + job_name + "_%j.out\n")
                    f.write("\n")
                    f.write("module purge\n")
                    f.write("module load/matlab2017a\n")
                    f.write("\n")
                    f.write("matlab -nosplash -nodesktop -nodisplay -r " +
                        "\"audio_name = \'taslp18_" + audio_name_str + "\'; " +
                        "modulations_str = \'" + modulations_str + "\'; " +
                        "J = " + J_str + "; " +
                        "wavelet_str = \'" + wavelet_str + "\'; " +
                        "addpath(genpath(\'~/scattering.m\')) " +
                        "addpath(genpath(\'~/export_fig\')); " +
                        "run('../taslp18_reconstructions.m');\"")
