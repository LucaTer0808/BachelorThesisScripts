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

MODELDIR="/scratch/tmp/lterfehr/models/SPNet"
VENV="${MODELDIR}/.venv"

TARGET_BASE="/scratch/tmp/lterfehr/model_results/SPNet"

execute_model() {
    local rgb="$1"
    local depth="$2"
    local gt="$3"
    local target="$4"

    echo "=== RGB Pfad: ${rgb} ==="
    echo "=== Depth Pfad: ${depth} ==="
    echo "=== GT Pfad: ${gt} ==="
    echo "=== Target Pfad: ${target} ==="

    if [ -d "${target}" ]; then
        rm -rf "${target}"
    fi

    mkdir -p "${target}"

    echo "=== Starte SPNet ==="
    python "${MODELDIR}"/test_produce_maps.py --rgb "${rgb}" --depth "${depth}" --gt "${gt}" --target "${target}"
    echo "=== SPNet beendet  --> $(date) ==="
}

RGB=(
    "/scratch/tmp/lterfehr/datasets/rgbd/DUT-OMRON_gen_depth/DUT-OMRON-image/"
    "/scratch/tmp/lterfehr/datasets/rgbd/DUTS_gen_depth/DUTS-TE/DUTS-TE-Image/"
    "/scratch/tmp/lterfehr/datasets/rgbd/LFSD/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/NJUD_gen_depth/test_data/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/RGBD135/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/ReDWeb-S_gen_depth/testset/RGB/"
    "/scratch/tmp/lterfehr/datasets/rgbd/SSD/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/STEREO/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/DUT-RGBD/test_data/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/ECSSD_gen_depth/images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/LFSD_gen_depth/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/NLPR/test_data/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/RGBD135_gen_depth/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/SIP/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/SSD_gen_depth/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/STEREO_gen_depth/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/DUT-RGBD_gen_depth/test_data/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/HKU-IS_gen_depth/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/NJUD/test_data/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/NLPR_gen_depth/test_data/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/ReDWeb-S/testset/RGB/"
    "/scratch/tmp/lterfehr/datasets/rgbd/SIP_gen_depth/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/STERE/test_images/"
    "/scratch/tmp/lterfehr/datasets/rgbd/STERE_gen_depth/test_images/"
)

DEPTH=(
    "/scratch/tmp/lterfehr/datasets/rgbd/DUT-OMRON_gen_depth/gen_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/DUTS_gen_depth/DUTS-TE/gen_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/LFSD/test_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/NJUD_gen_depth/test_data/gen_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/RGBD135/test_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/ReDWeb-S_gen_depth/testset/gen_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/SSD/test_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/STEREO/test_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/DUT-RGBD/test_data/test_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/ECSSD_gen_depth/gen_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/LFSD_gen_depth/gen_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/NLPR/test_data/test_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/RGBD135_gen_depth/gen_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/SIP/test_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/SSD_gen_depth/gen_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/STEREO_gen_depth/gen_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/DUT-RGBD_gen_depth/test_data/gen_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/HKU-IS_gen_depth/gen_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/NJUD/test_data/test_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/NLPR_gen_depth/test_data/gen_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/ReDWeb-S/testset/depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/SIP_gen_depth/gen_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/STERE/test_depth/"
    "/scratch/tmp/lterfehr/datasets/rgbd/STERE_gen_depth/gen_depth/"
)

GT=(
    "/scratch/tmp/lterfehr/datasets/rgbd/DUT-OMRON_gen_depth/pixelwiseGT-new-PNG"
    "/scratch/tmp/lterfehr/datasets/rgbd/DUTS_gen_depth/DUTS-TE/DUTS-TE-Mask/"
    "/scratch/tmp/lterfehr/datasets/rgbd/LFSD/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/NJUD_gen_depth/test_data/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/RGBD135/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/ReDWeb-S_gen_depth/testset/GT/"
    "/scratch/tmp/lterfehr/datasets/rgbd/SSD/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/STEREO/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/DUT-RGBD/test_data/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/ECSSD_gen_depth/ground_truth_mask/"
    "/scratch/tmp/lterfehr/datasets/rgbd/LFSD_gen_depth/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/NLPR/test_data/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/RGBD135_gen_depth/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/SIP/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/SSD_gen_depth/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/STEREO_gen_depth/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/DUT-RGBD_gen_depth/test_data/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/HKU-IS_gen_depth/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/NJUD/test_data/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/NLPR_gen_depth/test_data/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/ReDWeb-S/testset/GT/"
    "/scratch/tmp/lterfehr/datasets/rgbd/SIP_gen_depth/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/STERE/test_masks/"
    "/scratch/tmp/lterfehr/datasets/rgbd/STERE_gen_depth/test_masks/"
)

TARGET=(
    "${TARGET_BASE}/DUT-OMRON_gen_depth/"
    "${TARGET_BASE}/DUTS_gen_depth/"
    "${TARGET_BASE}/LFSD/"
    "${TARGET_BASE}/NJUD_gen_depth/"
    "${TARGET_BASE}/RGBD135/"
    "${TARGET_BASE}/ReDWeb-S_gen_depth/"
    "${TARGET_BASE}/SSD/"
    "${TARGET_BASE}/STEREO/"
    "${TARGET_BASE}/DUT-RGBD/"
    "${TARGET_BASE}/ECSSD_gen_depth/"
    "${TARGET_BASE}/LFSD_gen_depth/"
    "${TARGET_BASE}/NLPR/"
    "${TARGET_BASE}/RGBD135_gen_depth/"
    "${TARGET_BASE}/SIP/"
    "${TARGET_BASE}/SSD_gen_depth/"
    "${TARGET_BASE}/STEREO_gen_depth/"
    "${TARGET_BASE}/DUT-RGBD_gen_depth/"
    "${TARGET_BASE}/HKU-IS_gen_depth/"
    "${TARGET_BASE}/NJUD"
    "${TARGET_BASE}/NLPR_gen_depth/"
    "${TARGET_BASE}/ReDWeb-S/"
    "${TARGET_BASE}/SIP_gen_depth/"
    "${TARGET_BASE}/STERE/"
    "${TARGET_BASE}/STERE_gen_depth/"
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

mkdir -p "/scratch/tmp/lterfehr/BachelorThesisScripts/spnet-test/outs/" # for the output files

for ((i=0; i<COUNT; i++)); do
    echo "=== Starte SPNet für Dataset $((i + 1)) von ${COUNT} ==="
    execute_model "${RGB[i]}" "${DEPTH[i]}" "${GT[i]}" "${TARGET[i]}"
    echo "=== SPNet für Dataset $((i + 1)) von ${COUNT} beendet ==="
done

echo "=== Alle SPNet-Durchläufe abgeschlossen ==="


