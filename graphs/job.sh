#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=normal
#SBATCH --time=01:00:00

#SBATCH --job-name=create_graph
#SBATCH --output=outs/create_graph_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=ALL

module --force purge
module load palma/2023b
module load GCCcore/13.2.0
module load Python/3.11.5

VENV="/scratch/tmp/lterfehr/BachelorThesisScripts/graphs/.venv"

rm -rf "${VENV}"
python -m venv "${VENV}"
source "${VENV}/bin/activate"

pip install --quiet --upgrade pip
pip install --quiet -r "/scratch/tmp/lterfehr/BachelorThesisScripts/graphs/requirements.txt"

cd "/scratch/tmp/lterfehr/BachelorThesisScripts/graphs"
python create_graphs.py
python create_rgbd_graphs.py
python create_rgbd_graphs_pairwise.py

echo "=== Graphen wurden erfolgreich erstellt! ==="
