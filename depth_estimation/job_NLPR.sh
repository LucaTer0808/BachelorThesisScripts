#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuexpress
#SBATCH --gres=gpu:1

#SBATCH --job-name=nlpr_depth_estimation
#SBATCH --output=nlpr_depth_estimation_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de

# --- MODULE LADEN ---
module load palma/2023b
module load GCCcore/13.2.0
module load Python/3.11.5
module load CUDA/12.4.0

SOURCE_TEST="/scratch/tmp/lterfehr/datasets/rgbd/NLPR/test_data/test_images"
TARGET_TEST="/scratch/tmp/lterfehr/datasets/rgbd/NLPR_gen_depth/test_data/gen_depth"

SOURCE_TRAIN="/scratch/tmp/lterfehr/datasets/rgbd/NLPR/train_data/train_images"
TARGET_TRAIN="/scratch/tmp/lterfehr/datasets/rgbd/NLPR_gen_depth/train_data/gen_depth"

WORKDIR=/scratch/tmp/lterfehr/BachelorThesisScripts/depth_estimation

VENV=$WORKDIR/.venv_depth

# --- LOG-ORDNER ANLEGEN ---
mkdir -p $WORKDIR/logs

# --- VENV ERSTELLEN (nur beim ersten Mal) ---
if [ ! -d "$VENV" ]; then
    echo "Erstelle venv..."
    python -m venv $VENV
    source $VENV/bin/activate
    echo "Installiere PyTorch (cu121)..."
    pip install --quiet torch torchvision --index-url https://download.pytorch.org/whl/cu121
    echo "Installiere requirements.txt..."
    pip install --quiet -r $WORKDIR/requirements.txt
    echo "Installation abgeschlossen."
else
    echo "venv bereits vorhanden, überspringe Installation."
    source $VENV/bin/activate
fi

# --- LOG: UMGEBUNG CHECKEN ---
echo "Job gestartet: $(date)"
echo "Hostname: $(hostname)"
echo "Python: $(which python)"
echo "CUDA verfügbar: $(python -c 'import torch; print(torch.cuda.is_available())')"
echo "GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader)"

if [ -d "${TARGET_TEST}" ]; then
    echo "${TARGET_TEST} exists already. Deleting it for idempotency"
    rm -rf "${TARGET_TEST}"
fi

mkdir -p "${TARGET_TEST}"

if [ -d "${TARGET_TRAIN}" ]; then
    echo "${TARGET_TRAIN} exists already. Deleting it for idempotency"
    rm -rf "${TARGET_TRAIN}"
fi

mkdir -p "${TARGET_TRAIN}"

# --- SCRIPT AUSFÜHREN ---
python $WORKDIR/generate_depth_maps.py --source "${SOURCE_TEST}" --target "${TARGET_TEST}"
python $WORKDIR/generate_depth_maps.py --source "${SOURCE_TRAIN}" --target "${TARGET_TRAIN}"

echo "Job beendet: $(date)"
