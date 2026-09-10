#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpu2080
#SBATCH --gres=gpu:1

#SBATCH --job-name=come_e_rgbd_vst
#SBATCH --output=out/come_e_rgbd_vst_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=ALL


module --force purge
module load palma/2021b
module load CUDA/11.6.0
module load GCCcore/11.2.0
module load Python/3.9.6

MODELDIR="/scratch/tmp/lterfehr/models/VST/RGBD_VST"
VENV="${MODELDIR}/.venv"

RGB="/scratch/tmp/lterfehr/datasets/rgbd/COME-E/RGB"
DEPTH="/scratch/tmp/lterfehr/datasets/rgbd/COME-E/depths"
TARGET="/scratch/tmp/lterfehr/model_results/RGBD_VST/COME-E"

cd "${MODELDIR}"

nvidia-smi

if [ ! -d "${VENV}" ]; then
    echo "=== Keine alte venv gefunden. Lösche Verzeichnis === "
    python3 -m venv "${VENV}"
fi

source "${VENV}/bin/activate"

echo "=== Installiere requirements.txt ==="
pip install --quiet --upgrade pip
pip install --quiet -r "${MODELDIR}/requirements.txt"

if [ -d "${TARGET}" ]; then
    echo "${TARGET} already exists. Removing it ."
    rm -rf "${TARGET}"
fi

echo "=== Create ${TARGET} ==="
mkdir -p "${TARGET}"


echo "=== Starting VST RGB ==="
python ${MODELDIR}/train_test_eval.py --Testing --rgb="${RGB}" --depth="${DEPTH}" --target="${TARGET}"

echo "=== Job finished ==="
