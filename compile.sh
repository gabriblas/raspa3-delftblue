#!/bin/sh

#SBATCH --account=Education-ME-MSc-Me

#SBATCH --job-name="compile-raspa"
#SBATCH --output="%x-%j.log"
#SBATCH --partition=compute-p1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=2G
#SBATCH --time=02:00:00

set -e # stop execution on error

module purge
module load raspa/$RASPA_VERSION

cd "${raspa_source}"

cmake -B build --preset=delftblue-avx512-el8
ninja -C build
ninja -C build install