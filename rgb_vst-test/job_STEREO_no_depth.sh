#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuexpress
#SBATCH --gres=gpu:1

#SBATCH --job-name=stereo_no_depth_rgb_vst
#SBATCH --output=stereo_no_depth_rgb_vst_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=ALL

module --force purge
module load palma/2021b
module load CUDA/11.6.0
module load GCCcore/11.2.0

MODELDIR="/scratch/tmp/lterfehr/models/VST/RGB_VST"
VENV="${MODELDIR}/.venv"
SAVE_MODEL_DIR="${MODELDIR}/pretrained_model"

SOURCE="/scratch/tmp/lterfehr/datasets/rgb/STEREO_no_depth/test_images"
TARGET="/scratch/tmp/lterfehr/model_results/RGB_VST/STEREO_no_depth"

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

mkdir -p "${TARGET}"

echo "=== Starting VST RGB ==="

python ${MODELDIR}/train_test_eval.py --Testing --source="${SOURCE}" --target="${TARGET}" --save_model_dir="${SAVE_MODEL_DIR}"

echo "=== Job finished ==="
