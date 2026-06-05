#!/bin/bash -l

#SBATCH
#SBATCH --job-name="compileMITgcm"
#SBATCH --partition=compute
#SBATCH --time=00:05:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --account=research-ceg-he
#SBATCH --mem-per-cpu=1G
#SBATCH -o compile.out

set -euo pipefail

# Load modules on DelftBlue
module load 2025
module load openmpi/4.1.7
module load netcdf-c/4.9.2
module load netcdf-fortran/4.6.1

# Clear build
#rm -fr build
#mkdir build
echo $HOME



TUTORIAL_NAME=tutorial_barotropic_gyre

# set the MITgcm root dir
MITgcm_ROOT_DIR="${HOME}/repositories/GLOW-MITgcm"
export MITgcm_ROOT_DIR
# enable a logger function
LOGGER_PATH="${MITgcm_ROOT_DIR}/scripts/logger.sh"
export LOGFILEPATH="${MITgcm_ROOT_DIR}/logs/compile.log"
source "${LOGGER_PATH}"

# set the genmake2 path within the MITgcm root dir
GENMAKE2_PATH=${MITgcm_ROOT_DIR}/tools/genmake2

# optfile path for your HPC
OPTFILE_PATH=${MITgcm_ROOT_DIR}/tools/linux_amd64_gfortran_DB

# path to your code and the
CODE_AND_FILES_DIR=${MITgcm_ROOT_DIR}/verification/${TUTORIAL_NAME}

# project directory which include the build and the output directory later on.
BUILD_AND_OUTPUT_DIR="${HOME}/repositories/GLOW-MITgcm/nils-tutorials"
BUILD_PATH="${BUILD_AND_OUTPUT_DIR}/build"

# print out the 
# print out the 
cat << EOF
TUTORIAL_NAME : ${TUTORIAL_NAME}
MITgcm_ROOT_DIR : ${MITgcm_ROOT_DIR}
GENMAKE2_PATH : ${GENMAKE2_PATH}
OPTFILE_PATH : ${OPTFILE_PATH}
CODE_AND_FILES_DIR : ${CODE_AND_FILES_DIR}
BUILD_AND_OUTPUT_DIR : ${BUILD_AND_OUTPUT_DIR}
EOF


# validate the folders exist
mkdir -p "${MITgcm_ROOT_DIR}/logs" "${BUILD_PATH}"
for path in "${MITgcm_ROOT_DIR}" "${GENMAKE2_PATH}" "${OPTFILE_PATH}" "${CODE_AND_FILES_DIR}"; do
    if [ ! -e "${path}" ]; then
        echo "ERROR: Required path does not exist: ${path}" >&2
        logger "ERROR" "Required path does not exist: ${path}"
        exit 1
    fi
done

if [ ! -d "${BUILD_AND_OUTPUT_DIR}" ]; then
    mkdir -p "${BUILD_AND_OUTPUT_DIR}"
fi

logger "INFO" "Starting compilation for ${TUTORIAL_NAME}."

cat << EOF
----------------------------
MITgcm compilation starts!
$(date)
----------------------------
EOF


# set environment variable MPI_INC_DIR
whichString="$(which mpicc)"
newString="include"
oldString="bin/mpicc"
export MPI_INC_DIR=${whichString/$oldString/$newString} 

# set environment variable NETCDF_ROOT
whichString="$(which nc-config)"
newString=""
oldString="/bin/nc-config"
export NETCDF_ROOT=${whichString/$oldString/$newString}

# set environment variable NETCDF_FORTRAN_ROOT
whichString="$(which nf-config)"
newString=""
oldString="/bin/nf-config"
export NETCDF_FORTRAN_ROOT=${whichString/$oldString/$newString}

#mkdir -p build
#cd build

# move to build dir to build the model there
cd ${BUILD_AND_OUTPUT_DIR}/build
echo pwd
# GENMAKE2_PATH -rootdir=${MITgcm_ROOT_DIR} -mods=${CODE_AND_FILES_DIR}/code -optfile=${OPTFILE_PATH} -mpi
# #/work-zfs/thaine1/malmans2/MITgcmSep19/tools/genmake2 -rootdir=/work-zfs/thaine1/malmans2/MITgcmSep19 -mods=../code -optfile=../build_options/linux_amd64_ifort_MARCC -mpi

# # Create dependencies
# make depend

# # Create executable
# make all -j $(($SLURM_NNODES*$SLURM_NTASKS_PER_NODE))

logger "INFO" "MITgcm compilation finished successfully."

cat << EOF
----------------------------
MITgcm compilation finished!
Build can be found in ${BUILD_PATH}.
Executable can be found in ${BUILD_PATH}/mitgcmuv
$(date)
----------------------------
EOF


