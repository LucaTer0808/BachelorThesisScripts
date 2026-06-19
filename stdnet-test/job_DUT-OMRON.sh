#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuexpress
#SBATCH --gres=gpu:1

#SBATCH --job-name=ustdnet_on_dut_omron
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=None

module --force purge
module load palma/2022a
module load GCC/11.3.0
module load GCCcore/11.3.0
module load Python/3.10.4
module load CUDA/11.7.0
module load OpenMPI/4.1.4
module load torchvision/0.13.1
module load PyTorch/1.12.1-CUDA-11.7.0

WORKDIR=/scratch/tmp/lterfehr/BachelorThesisScripts/stdnet-test
MODELDIR=/scratch/tmp/lterfehr/models/stdnet
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

echo "=== Starte STDNet ... ==="

python $MODELDIR/generate_salmaps_flexible.py --source "/scratch/tmp/lterfehr/datasets/rgb/DUT-OMRON/DUT-OMRON-image" --target "/scratch/tmp/lterfehr/model_results/STDNet/DUT-OMRON"

echo "Job beendet: $(date)"
