#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuexpress
#SBATCH --gres=gpu:1
#SBATCH --time=01:00:00

#SBATCH --job-name=blueprint_caver
#SBATCH --output=outs/blueprint_caver_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=ALL

module --force purge
module load palma/2021b
module load GCCcore/11.2.0
module load CUDA/11.6.0
module load Python/3.9.6

MODELDIR="/scratch/tmp/lterfehr/models/CAVER"
OUTPUTS="${MODELDIR}/output"
PRETRAINED="${MODELDIR}/pretrained"

VENV="${MODELDIR}/.venv"

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

if [ -d "${OUTPUTS}" ]; then
    echo "${OUTPUTS} already exists. Removing it ."
    rm -rf "${OUTPUTS}"
fi

if [ -d "${PRETRAINED}" ]; then
    echo "${PRETRAINED} already exists. Removing it ."
    rm -rf "${PRETRAINED}"
fi

echo "=== Create ${OUTPUTS} ==="
mkdir -p "${OUTPUTS}"
echo "=== ${OUTPUTS} created ==="

echo "=== Create ${PRETRAINED} ==="
mkdir -p "${PRETRAINED}"
echo "=== ${PRETRAINED} created ==="

echo "=== Copy weights to ${PRETRAINED} ==="
cp -r "/scratch/tmp/lterfehr/parameters/CAVER/caver-r101d-rgbd-njudnlprdutrgbd.pt" "${PRETRAINED}"
echo "=== Copy finished ==="

echo "=== Starting CAVER ==="
python ${MODELDIR}/main.py --config ./configs/rgbd-all-datasets.py --model-name CAVER-R101D --info rgbt --load-from ./pretrained/caver-r101d-rgbd-njudnlprdutrgbd.pt --evaluate --show-bar
echo "=== CAVER finished ==="