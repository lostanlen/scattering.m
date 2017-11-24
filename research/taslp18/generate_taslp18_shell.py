import os
import sys


audio_names = ['dog-bark', 'flute'];
modulations_strs = ['none', 'time', 'time-frequency'];
wavelet_strs = ['morlet'];
Js = [13, 15, 17];


os.makedirs("sbatch", exist_ok=True)
os.makedirs("slurm", exist_ok=True)

# Loop over recording units.
for audio_name_str in audio_names:

    # Loop over Js.
    for J in Js:

        J_str = str(J)

        file_path = os.path.join(
            "sbatch",
            "taslp18_name=" + audio_name_str + "_J=" + J_str + ".sh")

        with open(file_path, "w") as f:

            # Print header.
            f.write(
                "# This shell script executes the Slurm jobs for computing " +
                "reconstructions.\n")
            f.write("\n")

            # Loop over modulations.
            for modulations_str in modulations_strs:

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
                    command_str = "sbatch " + file_name

                    f.write(command_str + "\n")

            # Grant permission to execute the shell file.
            # https://stackoverflow.com/a/30463972
            mode = os.stat(file_path).st_mode
            mode |= (mode & 0o444) >> 2
            os.chmod(file_path, mode)
