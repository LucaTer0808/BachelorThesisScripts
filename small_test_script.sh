#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuexpress
#SBATCH --gres=gpu:1
#SBATCH --time=10:00:00

#SBATCH --job-name=f3net
#SBATCH --output=outs/f3net_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=ALL

module --force purge
module load palma/2021b
module load GCCcore/11.2.0
module load Python/3.9.6
module load CUDA/11.6.0

nvidia-smi

