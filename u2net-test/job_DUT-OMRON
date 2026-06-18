#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuexpress
#SBATCH --gres=gpu:1

#SBATCH --job-name=u2net_on_dut_omron
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de

module load palma/2023b
module load palma/2023a
module load GCCcore/13.2.0
module load Python/3.11.5
module load CUDA/12.1.1

WORKDIR=/scratch/tmp/lterfehr/BachelorThesisScripts/u2net-test
MODELDIR=/scratch/tmp/lterfehr/models/U-2-Net
VENV=$MODELDIR/.venv

cd "$MODELDIR"

if [ ! -d "$VENV" ]; then
    echo "Erstelle venv..."
    python3 -m venv $VENV
    source $VENV/bin/activate
    echo "Installiere requirements.txt..."
    pip install --quiet -r $MODELDIR/requirements.txt
    echo "Installation abgeschlossen."
else
    echo "venv bereits vorhanden, überspringe Installation."
    source $VENV/bin/activate
fi

echo "Starte U2-Net ..."

python $MODELDIR/u2net_test.py --source "/scratch/tmp/lterfehr/datasets/rgb/DUT-OMRON/DUT-OMRON-image" --target "/scratch/tmp/lterfehr/model_results/U-2-Net/DUT-OMRON"

echo "Job beendet: $(date)"