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
module load palma/2023b
module load GCCcore/13.2.0
module load Python/3.11.5

# ABSOLUTER PFAD ZUR VENV
VENV_DIR="/scratch/tmp/lterfehr/BachelorThesisScripts/eval/.venv"
source "/scratch/tmp/lterfehr/BachelorThesisScripts/target_bases.sh"

rm -rf "${VENV_DIR}"
python -m venv "${VENV_DIR}"
source "${VENV_DIR}/bin/activate"

echo "=== Installiere requirements.txt in Scratch-Venv ==="

pip install --upgrade pip
pip install -r "/scratch/tmp/lterfehr/BachelorThesisScripts/eval/requirements.txt"

echo "=== Starte Evaluation für RGBD Modelle ==="

for ((x=0;x<${BASES_COUNT};x++)); do
    echo "=== Evaluation für Model $((x + 1)) von ${BASES_COUNT} ==="
    export TARGET_BASE="${RGBD_TARGET_BASES[x]}"

    source "/scratch/tmp/lterfehr/BachelorThesisScripts/rgbd_datasets.sh"

    for ((y=0; y<${COUNT}; y++)); do

        echo "=== Dataset $((y + 1)) von ${COUNT} ==="
        echo "=== GT Pfad: ${GT[y]} ==="
        echo "=== Target Pfad: ${TARGET[y]} ==="
        echo ""

        cd "/scratch/tmp/lterfehr/BachelorThesisScripts/eval"
        python eval.py --gt "${GT[y]}" --pred "${TARGET[y]}"
    done

    echo ""
done

echo "=== Starte Evaluation für RGB Modelle ==="

for ((a=0;a<${BASES_COUNT};a++)); do
    echo "=== Evaluation für Model $((a + 1)) von ${BASES_COUNT} ==="
    export TARGET_BASE="${RGB_TARGET_BASES[a]}"

    source "/scratch/tmp/lterfehr/BachelorThesisScripts/rgb_datasets.sh"

    for ((b=0; b<${COUNT}; b++)); do

        echo "=== Dataset $((b + 1)) von ${COUNT} ==="
        echo "=== GT Pfad: ${GT[b]} ==="
        echo "=== Target Pfad: ${TARGET[b]} ==="
        echo ""

        cd "/scratch/tmp/lterfehr/BachelorThesisScripts/eval"
        python eval.py --gt "${GT[b]}" --pred "${TARGET[b]}"
    done

    echo ""
done