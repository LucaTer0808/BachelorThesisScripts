#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuexpress
#SBATCH --gres=gpu:1
#SBATCH --time=01:00:00

#SBATCH --job-name=u2net
#SBATCH --output=outs/u2net_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=ALL

bash job_DUT-OMRON.sh
bash job_DUT-RGBD_no_depth.sh
bash job_DUTS.sh
bash job_ECSSD.sh
bash job_HKU-IS.sh
bash job_LFSD_no_depth.sh
bash job_NJUD_no_depth.sh
bash job_NLPR_no_depth.sh
bash job_ReDWeb-S_no_depth.sh
bash job_RGBD135_no_depth.sh
bash job_SIP_no_depth.sh
bash job_SSD_no_depth.sh
bash job_STERE_no_depth.sh
bash job_STEREO_no_depth.sh

echo "=== Job finished ==="