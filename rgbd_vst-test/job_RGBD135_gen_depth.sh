#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuexpress
#SBATCH --gres=gpu:1

#SBATCH --job-name=rgbd135_gen_depth_rgbd_vst
#SBATCH --output=rgbd135_gen_depth_rgbd_vst_%j.out
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


RGB="/scratch/tmp/lterfehr/datasets/rgbd/RGBD135_gen_depth/test_images"
DEPTH="/scratch/tmp/lterfehr/datasets/rgbd/RGBD135_gen_depth/gen_depth"
TARGET="/scratch/tmp/lterfehr/model_results/RGBD_VST/RGBD135_gen_depth"

cd "${MODELDIR}"

nvidia-smi

if [ -d "${VENV}" ]; then
    echo "=== Alte venv gefunden. Lösche Verzeichnis === "
    rm -rf "${VENV}"
fi

echo "=== Erstelle venv komplett neu ==="
python3 -m venv "${VENV}"
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
