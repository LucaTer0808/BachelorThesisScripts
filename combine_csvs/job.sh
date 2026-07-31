#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpu2080
#SBATCH --gres=gpu:1
#SBATCH --time=10:00:00

#SBATCH --job-name=combine_csvs
#SBATCH --output=outs/combine_csvs_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=ALL

module --force purge
module load palma/2023b
module load GCCcore/13.2.0
module load Python/3.11.5

VENV="/scratch/tmp/lterfehr/BachelorThesisScripts/combine_csvs/.venv"

rm -rf "${VENV}"
python -m venv "${VENV}"
source "${VENV}/bin/activate"

pip install --quiet --upgrade pip
pip install --quiet -r "/scratch/tmp/lterfehr/BachelorThesisScripts/combine_csvs/requirements.txt"

cd "/scratch/tmp/lterfehr/BachelorThesisScripts/combine_csvs"
python combine.py
python combine_pr_curves.py

echo "=== CSVs wurden erfolgreich zusammengeführt! ==="