#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpu2080
#SBATCH --gres=gpu:1
#SBATCH --time=02:00:00

#SBATCH --job-name=size_check_come_e
#SBATCH --output=outs/rsize_check_come_e_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=ALL

module load palma/2023b
module load GCCcore/13.2.0
module load Python/3.11.5
module load CUDA/12.4.0

DIR="/scratch/tmp/lterfehr/BachelorThesisScripts/check_sizes"
VENV="${DIR}/.venv"

X="/scratch/tmp/lterfehr/datasets/rgbd/COME-E/RGB"
Y="/scratch/tmp/lterfehr/datasets/rgbd/COME-E/depths"

if [ ! -d "${VENV}" ]; then
    echo "=== Keine alte venv gefunden. Erstelle neue === "
    python3 -m venv "${VENV}"
fi

source "${VENV}/bin/activate"

pip install --quiet --upgrade pip
pip install --quiet -r "${DIR}/requirements.txt"

python "${DIR}/check_sizes.py" --folder_1="${X}" --folder_2="${Y}"