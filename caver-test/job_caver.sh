#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpu2080
#SBATCH --gres=gpu:1
#SBATCH --time=01:00:00

#SBATCH --job-name=job_caver
#SBATCH --output=outs/job_caver_%j.out
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
TARGET="/scratch/tmp/lterfehr/model_results/CAVER"

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
python ${MODELDIR}/main.py --config ./configs/rgbd-all-datasets.py --model-name CAVER_R101D --info rgbt --load-from ./pretrained/caver-r101d-rgbd-njudnlprdutrgbd.pt --evaluate --show-bar
echo "=== CAVER finished ==="


echo "=== Prepare moving result images ==="
if [ -d ${TARGET} ]; then
    echo "${TARGET} already exists. Removing it and creating a new one."
    rm -rf "${TARGET}"
fi

mkdir -p "${TARGET}"

echo "=== Preparation finished ==="

echo "=== Moving result images ==="
cd "${OUTPUTS}/CAVER_R101D_256x256_BS8_E100_AMPy_LR0.005_OTall_OPsgd_LTcos_INFOrgbt/exp_0/pre"

mv "DUTS_GEN_DEPTH" "${TARGET}/DUTS_gen_depth"
mv "DUT_RGBD_GEN_DEPTH" "${TARGET}/DUT-RGBD_gen_depth"
mv "LFSD" "${TARGET}/LFSD"
mv "NJUD_GEN_DEPTH" "${TARGET}/NJUD_gen_depth"
mv "RGBD135" "${TARGET}/RGBD135"
mv "SIP_GEN_DEPTH" "${TARGET}/SIP_gen_depth"
mv "STERE" "${TARGET}/STERE"
mv "STERE_GEN_DEPTH" "${TARGET}/STERE_gen_depth"
mv "DUT_OMRON_GEN_DEPTH" "${TARGET}/DUT-OMRON_gen_depth"
mv "ECSSD_GEN_DEPTH" "${TARGET}/ECSSD_gen_depth"
mv "LFSD_GEN_DEPTH" "${TARGET}/LFSD_gen_depth"
mv "NLPR" "${TARGET}/NLPR"
mv "REDWEB_S" "${TARGET}/ReDWeb-S"
mv "RGBD135_GEN_DEPTH" "${TARGET}/RGBD135_gen_depth"
mv "SSD" "${TARGET}/SSD"
mv "STEREO" "${TARGET}/STEREO"
mv "DUT_RGBD" "${TARGET}/DUT-RGBD"
mv "HKU_IS_GEN_DEPTH" "${TARGET}/HKU-IS_gen_depth"
mv "NJUD" "${TARGET}/NJUD"
mv "NLPR_GEN_DEPTH" "${TARGET}/NLPR_gen_depth"
mv "REDWEB_S_GEN_DEPTH" "${TARGET}/ReDWeb-S_gen_depth"
mv "SIP" "${TARGET}/SIP"
mv "SSD_GEN_DEPTH" "${TARGET}/SSD_gen_depth"
mv "STEREO_GEN_DEPTH" "${TARGET}/STEREO_gen_depth"