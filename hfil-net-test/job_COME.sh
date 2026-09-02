#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpu2080
#SBATCH --gres=gpu:1
#SBATCH --time=10:00:00

#SBATCH --job-name=hfil_net
#SBATCH --output=outs/hfil_net_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=ALL

bash job_COME-E.sh
bash job_COME-E_gen_depth.sh
bash job_COME-H.sh
bash job_COME-H_gen_depth.sh
