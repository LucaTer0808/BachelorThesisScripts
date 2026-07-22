#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuexpress
#SBATCH --gres=gpu:1
#SBATCH --time=10:00:00

#SBATCH --job-name=check_valid_size_rgb
#SBATCH --output=outs/check_valid_size_rgb_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=ALL

module --force purge
module load palma/2023b
module load GCCcore/13.2.0
module load Python/3.11.5

VENV="/scratch/tmp/lterfehr/BachelorThesisScripts/check_valid_size/.venv"
source "/scratch/tmp/lterfehr/BachelorThesisScripts/target_bases.sh"

if [ -d "${VENV}" ]; then
    rm -rf "${VENV}"
fi

python -m venv "${VENV}"
source "${VENV}/bin/activate"

pip install --quiet --upgrade pip
pip install --quiet -r "/scratch/tmp/lterfehr/BachelorThesisScripts/check_valid_size/requirements.txt"

for ((j=0;j<${BASES_COUNT};j++)); do
    echo "=== Model $((j + 1)) von ${BASES_COUNT} ==="
    export TARGET_BASE="${TARGET_BASES[j]}"

    source "/scratch/tmp/lterfehr/BachelorThesisScripts/rgb_datasets.sh"

    for ((i=0; i<${COUNT}; i++)); do

        echo "=== Dataset $((i + 1)) von ${COUNT} ==="
        echo "=== GT Pfad: ${GT[i]} ==="
        echo "=== Target Pfad: ${TARGET[i]} ==="

        python check_valid_size.py --gt "${GT[i]}" --target "${TARGET[i]}"
    done
done