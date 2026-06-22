#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuexpress
#SBATCH --gres=gpu:1

#SBATCH --job-name=njud_gen_depth_hfil_net
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=ALL

module --force purge
module load palma/2020b
module load GCC/10.2.0
module load GCCcore/10.2.0
module load Python/3.8.6
module load CUDA/11.1.1

MODELDIR="/scratch/tmp/lterfehr/models/HFIL-Net"
VENV="${MODELDIR}/.venv"

RGB="/scratch/tmp/lterfehr/datasets/rgbd/NJUD_gen_depth/test_data/test_images"
GT="/scratch/tmp/lterfehr/datasets/rgbd/NJUD_gen_depth/test_data/test_masks"
DEPTH="/scratch/tmp/lterfehr/datasets/rgbd/NJUD_gen_depth/test_data/gen_depth"

OUTDIR="/scratch/tmp/lterfehr/model_results/HFIL-Net/NJUD_gen_depth"

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

echo "=== Setup der virtuellen Umgebung abgeschlossen ==="

echo "=== Starte HFIL-Net ... ==="

python ${MODELDIR}/HFILNet_test.py --rgb_path="${RGB}" --gt_path="${GT}" --depth_path="${DEPTH}" --target="${OUTDIR}"

echo "Job beendet: $(date)"
