#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuexpress
#SBATCH --gres=gpu:1

#SBATCH --job-name=lfsd_depth_estimation
#SBATCH --output=lfsd_depth_estimation_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de

# --- MODULE LADEN ---
module load palma/2023b
module load GCCcore/13.2.0
module load Python/3.11.5
module load CUDA/12.4.0

SOURCE="/scratch/tmp/lterfehr/datasets/rgbd/LFSD/test_images"
TARGET="/scratch/tmp/lterfehr/datasets/rgbd/LFSD_gen_depth/gen_depth"
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

if [ -d "${TARGET}" ]; then
    echo "${TARGET} exists already. Deleting it for idempotency"
    rm -rf "${TARGET}"
fi

mkdir -p "${TARGET}"

# --- SCRIPT AUSFÜHREN ---
python $WORKDIR/generate_depth_maps.py --source "${SOURCE}" --target "${TARGET}"

echo "Job beendet: $(date)"







