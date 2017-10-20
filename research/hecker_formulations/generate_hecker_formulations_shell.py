import os
import sys

file_path = 'hecker_formulations.sh'
n_files = 72

# Open shell file.
with open(file_path, "w") as f:
    # Print header.
    f.write(
        "# This shell script executes the Slurm jobs for computing " +
        "text files associated to Florian Hecker's formulations.\n")
    f.write("\n")

    # Loop over recording units.
    for file_id in range(1, 1+n_files):
        # Define job name.
        job_name = "hecker_formulations_" + str(file_id).zfill(2)
        sbatch_str = "sbatch " + job_name + ".sbatch"

        # Write SBATCH command to shell file.
        f.write(sbatch_str + "\n")


# Grant permission to execute the shell file.
# https://stackoverflow.com/a/30463972
mode = os.stat(file_path).st_mode
mode |= (mode & 0o444) >> 2
os.chmod(file_path, mode)
