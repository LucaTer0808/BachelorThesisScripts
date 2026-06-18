#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuexpress
#SBATCH --gres=gpu:1

#SBATCH --job-name=u2net_on_pascal_s
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=None

module --force purge
module load palma/2023b
module load GCCcore/13.2.0
module load Python/3.11.5
module load CUDA/12.4.0

WORKDIR=/scratch/tmp/lterfehr/BachelorThesisScripts/u2net-test
MODELDIR=/scratch/tmp/lterfehr/models/U-2-Net
VENV=$MODELDIR/.venv

cd "$MODELDIR"

if [ -d "$VENV" ]; then
    echo "=== Alte venv gefunden. Lösche Verzeichnis === "
    rm -rf "$VENV"
fi

echo "=== Erstelle venv komplett neu ==="
python3 -m venv "$VENV"
source "$VENV/bin/activate"

echo "=== Installiere requirements.txt ==="
pip install --quiet --upgrade pip
pip install --quiet -r "$MODELDIR/requirements.txt"

echo "=== Setup der virtuellen Umgebung abgeschlossen ==="

echo "Starte U2-Net ..."

python $MODELDIR/u2net_test.py --source "/scratch/tmp/lterfehr/datasets/rgb/PASCAL-S/test_images" --target "/scratch/tmp/lterfehr/model_results/U-2-Net/PASCAL-S/test"

echo "Job beendet: $(date)"
