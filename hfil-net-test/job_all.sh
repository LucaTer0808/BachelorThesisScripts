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

module --force purge
module load palma/2020b
module load GCC/10.2.0
module load GCCcore/10.2.0
module load Python/3.8.6
module load CUDA/11.1.1

bash job_DUT-OMRON_gen_depth.sh
bash job_DUT-RGBD_gen_depth.sh
bash job_DUT-RGBD.sh
bash job_DUTS_gen_depth.sh
bash job_ECSSD_gen_depth.sh
bash job_HKU-IS_gen_depth.sh
bash job_LFSD_gen_depth.sh
bash job_LFSD.sh
bash job_NJUD_gen_depth.sh
bash job_NJUD.sh
bash job_NLPR_gen_depth.sh
bash job_NLPR.sh
bash job_ReDWeb-S_gen_depth.sh
bash job_ReDWeb-S.sh
bash job_RGBD135_gen_depth.sh
bash job_RGBD135.sh
bash job_SIP_gen_depth.sh
bash job_SIP.sh
bash job_SSD_gen_depth.sh
bash job_SSD.sh
bash job_STERE_gen_depth.sh
bash job_STERE.sh
bash job_STEREO_gen_depth.sh
bash job_STEREO.sh
bash job_COME-E.sh
bash job_COME-E_gen_depth.sh
bash job_COME-H.sh
bash job_COME-H_gen_depth.sh
