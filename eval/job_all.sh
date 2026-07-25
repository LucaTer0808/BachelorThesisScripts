#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpu2080
#SBATCH --gres=gpu:1
#SBATCH --time=10:00:00

#SBATCH --job-name=evaluation
#SBATCH --output=outs/evaluation_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=ALL

module --force purge
module load palma/2025a
module load GCCcore/14.2.0
module load Python/3.13.1

VENV="/scratch/tmp/lterfehr/BachelorThesisScripts/eval/.venv"

if [ -d "${VENV}" ]; then
    echo "=== Alte venv gefunden. Lösche Verzeichnis === "
    rm -rf "${VENV}"
fi

echo "=== Erstelle venv komplett neu ==="
python3 -m venv "${VENV}"
source "${VENV}/bin/activate"

echo "=== Installiere requirements.txt ==="
pip install --upgrade pip
pip install -r "/scratch/tmp/lterfehr/BachelorThesisScripts/eval/requirements.txt"

source "/scratch/tmp/lterfehr/BachelorThesisScripts/target_bases.sh"

echo "=== Starte Evaluation für RGBD Modelle ==="

for ((i=0; i<BASES_COUNT; i++)); do
    TARGET_BASE="${RGBD_TARGET_BASES[$i]}"
    source "/scratch/tmp/lterfehr/BachelorThesisScripts/rgbd_datasets.sh"

    echo "=== Starte Evaluation für ${TARGET_BASE} ==="
    cd "/scratch/tmp/lterfehr/BachelorThesisScripts/eval/"

    python eval.py --gt "${GT[i]}" --pred "${TARGET[i]}"
done

echo "=== Starte Evaluation für RGB Modelle ==="

for ((j=0; j<BASES_COUNT; j++)); do
    TARGET_BASE="${RGB_TARGET_BASES[$j]}"
    source "/scratch/tmp/lterfehr/BachelorThesisScripts/rgb_datasets.sh"

    echo "=== Starte Evaluation für ${TARGET_BASE} ==="
    cd "/scratch/tmp/lterfehr/BachelorThesisScripts/eval/"

    python eval.py --gt "${GT[j]}" --pred "${TARGET[j]}"
done