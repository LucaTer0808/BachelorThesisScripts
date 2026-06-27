#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuexpress
#SBATCH --gres=gpu:1
#SBATCH --time=10:00:00

#SBATCH --job-name=spnet
#SBATCH --output=outs/spnet_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=ALL

module --force purge
module load palma/2021b
module load GCCcore/11.2.0
module load Python/3.9.6
module load CUDA/11.6.0

MODELDIR="/scratch/tmp/lterfehr/models/CTIF-Net"
VENV="${MODELDIR}/.venv"

TARGET_BASE="/scratch/tmp/lterfehr/model_results/CTIF-Net"

execute_model() {
    local rgb="$1"
    local gt="$2"
    local target="$3"

    echo "=== RGB Pfad: ${rgb} ==="
    echo "=== GT Pfad: ${gt} ==="
    echo "=== Target Pfad: ${target} ==="

    if [ -d "${target}" ]; then
        rm -rf "${target}"
    fi

    mkdir -p "${target}"

    echo "=== Starte CTIF-Net ==="
    python "${MODELDIR}"/test.py --source "${rgb}" --gt "${gt}" --target "${target}"
    echo "=== CTIF-Net beendet  --> $(date) ==="
}

RGB=(
    "/scratch/tmp/lterfehr/datasets/rgb/DUT-OMRON/DUT-OMRON-image/"
    "/scratch/tmp/lterfehr/datasets/rgb/DUTS/DUTS-TE/DUTS-TE-Image/"
    "/scratch/tmp/lterfehr/datasets/rgb/HKU-IS/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgb/NJUD_no_depth/test_data/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgb/RGBD135_no_depth/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgb/SIP_no_depth/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgb/STEREO_no_depth/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgb/DUT-RGBD_no_depth/test_data/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgb/ECSSD/images/"
    "/scratch/tmp/lterfehr/datasets/rgb/LFSD_no_depth/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgb/NLPR_no_depth/test_data/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgb/ReDWeb-S_no_depth/testset/RGB/"
    "/scratch/tmp/lterfehr/datasets/rgb/SSD_no_depth/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgb/STERE_no_depth/test_images/"
    )


GT=(
    "/scratch/tmp/lterfehr/datasets/rgb/DUT-OMRON/pixelwiseGT-new-PNG/"
    "/scratch/tmp/lterfehr/datasets/rgb/DUTS/DUTS-TE/DUTS-TE-Mask/"
    "/scratch/tmp/lterfehr/datasets/rgb/HKU-IS/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgb/NJUD_no_depth/test_data/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgb/RGBD135_no_depth/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgb/SIP_no_depth/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgb/STEREO_no_depth/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgb/DUT-RGBD_no_depth/test_data/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgb/ECSSD/ground_truth_mask/"
    "/scratch/tmp/lterfehr/datasets/rgb/LFSD_no_depth/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgb/NLPR_no_depth/test_data/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgb/ReDWeb-S_no_depth/testset/GT/"
    "/scratch/tmp/lterfehr/datasets/rgb/SSD_no_depth/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgb/STERE_no_depth/test_masks/"
)

TARGET=(
    "${TARGET_BASE}/DUT-OMRON/"
    "${TARGET_BASE}/DUTS/"
    "${TARGET_BASE}/HKU-IS/"
    "${TARGET_BASE}/NJUD_no_depth/"
    "${TARGET_BASE}/RGBD135_no_depth/"
    "${TARGET_BASE}/SIP_no_depth/"
    "${TARGET_BASE}/STEREO_no_depth/"
    "${TARGET_BASE}/DUT-RGBD_no_depth/"
    "${TARGET_BASE}/ECSSD/"
    "${TARGET_BASE}/LFSD_no_depth/"
    "${TARGET_BASE}/NLPR_no_depth/"
    "${TARGET_BASE}/ReDWeb-S_no_depth/"
    "${TARGET_BASE}/SSD_no_depth/"
    "${TARGET_BASE}/STERE_no_depth/"
)

COUNT="${#RGB[@]}"

cd "${MODELDIR}"

if [ -d "${VENV}" ]; then
    rm -rf "${VENV}"
fi

python -m venv "${VENV}"
source "${VENV}/bin/activate"

pip install --quiet --upgrade pip
pip install --quiet -r "${MODELDIR}/requirements.txt"

for ((i=0; i<COUNT; i++)); do
    echo "=== Starte CTIF-Net für Dataset $((i + 1)) von ${COUNT} ==="
    execute_model "${RGB[i]}" "${GT[i]}" "${TARGET[i]}"
    echo "=== CTIF-Net für Dataset $((i + 1)) von ${COUNT} beendet ==="
done

echo "=== Alle CTIF-Net-Durchläufe abgeschlossen ==="


