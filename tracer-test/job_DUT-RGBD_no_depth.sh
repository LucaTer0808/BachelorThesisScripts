#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuexpress
#SBATCH --gres=gpu:1

#SBATCH --job-name=dut_rgbd_no_depth_tracer
#SBATCH --output=outs/dut_rgbd_no_depth_tracer_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=ALL

module --force purge
module load palma/2021b
module load GCCcore/11.2.0
module load CUDA/11.6.0

MODELDIR="/scratch/tmp/lterfehr/models/TRACER"
VENV="${MODELDIR}/.venv"

SOURCE="/scratch/tmp/lterfehr/datasets/rgb/DUT-RGBD_no_depth/test_data/test_images"
TARGET="/scratch/tmp/lterfehr/model_results/TRACER/DUT-RGBD_no_depth"

cd "${MODELDIR}"

if [ -d "${VENV}" ]; then
    echo "=== Alte venv gefunden. Lösche Verzeichnis === "
    rm -rf "${VENV}"
fi

echo "=== Erstelle venv komplett neu ==="
python -m venv "${VENV}"
source "${VENV}/bin/activate"
echo "=== venv aktiviert ==="
echo "=== Installiere requirements.txt ==="
pip install --quiet --upgrade pip
pip install --quiet -r "${MODELDIR}/requirements.txt"
echo "=== requirements.txt installiert ==="

if [ -d "${TARGET}" ]; then
    echo "${TARGET} already exists. Removing it ."
    rm -rf "${TARGET}"
fi

if [ ! -d ${MODELDIR}/data/dataset ]; then
    echo "=== ${MODELDIR}/data/dataset does not exist. Create it ==="
    mkdir -p "${MODELDIR}/data/dataset"
    echo "=== ${MODELDIR}/data/dataset created ==="
fi

if [ ! -d ${MODELDIR}/mask/dataset ]; then
    echo "=== ${MODELDIR}/mask/dataset does not exist. Create it ==="
    mkdir -p "${MODELDIR}/mask/dataset"
    echo "=== ${MODELDIR}/mask/dataset created ==="
fi

echo "=== Create ${TARGET} ==="
mkdir -p "${TARGET}"
echo "=== ${TARGET} created ==="

echo "=== Clear Workspace ==="
rm -rf "${MODELDIR}/data/dataset/"*
rm -rf "${MODELDIR}/mask/dataset/"*
echo "=== Workspace cleared ==="

echo "=== Copy ${SOURCE} to ${MODELDIR}/data/dataset/ ==="
cp -r "${SOURCE}"/* "${MODELDIR}/data/dataset/"
echo "=== Copy finished ==="

echo "=== Starting TRACER ==="
python ${MODELDIR}/main.py inference --dataset dataset/ --arch 1 --img_size 320 --save_map True
echo "=== Tracer finished ==="

echo "=== Copy ${MODELDIR}/mask/dataset/* to ${TARGET} ==="
cp -r "${MODELDIR}/mask/dataset/"* "${TARGET}"
echo "=== Copy finished ==="

