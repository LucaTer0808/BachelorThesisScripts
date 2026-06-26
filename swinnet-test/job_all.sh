#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuexpress
#SBATCH --gres=gpu:1
#SBATCH --time=10:00:00

#SBATCH --job-name=swinnet
#SBATCH --output=outs/swinnet_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=ALL

module --force purge
module load palma/2021b
module load GCCcore/11.2.0
module load Python/3.9.6
module load CUDA/11.6.0

MODELDIR="/scratch/tmp/lterfehr/models/SwinNet"
VENV="${MODELDIR}/.venv"
TARGET_BASE="/scratch/tmp/lterfehr/model_results/SwinNet"


source "/scratch/tmp/lterfehr/BachelorThesisScripts/rgbd_datasets.sh"

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

    python "${MODELDIR}"/SwinNet_test.py --rgb "${rgb}" --depth "${depth}" --gt "${gt}" --target "${target}"
}

cd "${MODELDIR}"

if [ -d "${VENV}" ]; then
    rm -rf "${VENV}"
fi

python -m venv "${VENV}"
source "${VENV}/bin/activate"

pip install --quiet --upgrade pip
pip install --quiet -r "${MODELDIR}/requirements.txt"

for ((i=0; i<COUNT; i++)); do
    echo "=== Starte SwinNet für Dataset $((i + 1)) von ${COUNT} ==="
    execute_model "${RGB[i]}" "${DEPTH[i]}" "${GT[i]}" "${TARGET[i]}"
    echo "=== SwinNet für Dataset $((i + 1)) von ${COUNT} beendet ==="
done

echo "=== Alle SwinNet-Durchläufe abgeschlossen ==="