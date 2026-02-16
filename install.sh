#!/bin/sh

set -o errexit # exit on any error

# input variables (can be changed!)
export RASPA_VERSION="3.0.21"
export INSTALL_DIR="${HOME}/raspa/"
export LMOD_DIR="${INSTALL_DIR}/modules/"

# setup directories
echo "Setting up directories and files..."
export INSTALL_PREFIX="${INSTALL_DIR}/${RASPA_VERSION}/"
mkdir -p "${INSTALL_PREFIX}"
mkdir -p "${LMOD_DIR}/raspa"

# common variables for the CMakePreset and lmod script
export INTEL_DIR="/apps/generic/intel/oneapi_2022.3/compiler/2022.2.0/linux"
export LLVM_DIR="/apps/generic/compiler/2025/software/linux-rhel8-x86_64_v3/gcc-8.5.0/llvm-19.1.3-nfdvssat7bt23mnawcfh5gh42xfemucu"
export VORO_DIR="/apps/arch/2025/software/linux-rhel8-cascadelake/gcc-13.3.0/voropp-0.4.6-5rrufeh7upoip3h2fdvz5vobrhueuuyt"

# create module file
cat > "${LMOD_DIR}/raspa/${RASPA_VERSION}.lua" <<EOL
whatis("Name: raspa")
whatis("Version: ${RASPA_VERSION}")
whatis("Keywords: Molecular, Simulation, Montecarlo")
whatis("URL: https://github.com/iRASPA/RASPA3/tree/main")
whatis("Description: General purpose classical simulation package")

depends_on("2025")
depends_on("llvm/19.1.3")
depends_on("openmpi/4.1.7")
depends_on("cmake/3.30.5")
depends_on("ninja/1.12.1")
depends_on("py-pybind11/2.13.5")
depends_on("openblas/0.3.28_threads_openmp")
depends_on("hdf5/1.14.3")
depends_on("intel/oneapi")
depends_on("init_opencl/2022.2.0")
depends_on("voropp/0.4.6")

prepend_path("LD_LIBRARY_PATH", "${INTEL_DIR}/compiler/lib/intel64")
prepend_path("LD_LIBRARY_PATH", "${INTEL_DIR}/lib")
prepend_path("LD_LIBRARY_PATH", "${LLVM_DIR}/lib/x86_64-unknown-linux-gnu")

prepend_path("PATH","${INSTALL_PREFIX}/bin")

EOL

module use "${LMOD_DIR}"

# get raspa source and patch the new cmake preset and lists
echo "Downloading and extracting raspa v${RASPA_VERSION}"
wget --quiet "https://github.com/iRASPA/RASPA3/archive/refs/tags/v${RASPA_VERSION}.tar.gz"
tar -xf "v${RASPA_VERSION}.tar.gz"
export RASPA_SOURCE=$(tar -tzf "v${RASPA_VERSION}.tar.gz" | head -1)
cp --force --recursive patch/* "${RASPA_SOURCE}"

# compile on compute
echo "Compiling raspa. It'll take a while, so grab a coffee and have a look at the slurm log!"
sbatch compile.sh

echo "In the meantime, you can add 'module use \"${LMOD_DIR}\"' to your .bashrc to be able to run 'module load raspa'"