#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuexpress
#SBATCH --gres=gpu:1

#SBATCH --job-name=
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=ALL

MODELDIR="/scratch/tmp/lterfehr/models/VST/RGB_VST"
SAVE_MODEL_DIR="/scratch/tmp/lterfehr/models/VST/pretrained_model"
SOURCE=""
TARGET=""

if [ -d "${TARGET}" ]; then
    echo "${TARGET} already exists. Removing it ."
    rm -rf "${TARGET}"
fi

python ${WORKDIR}/train_test_eval.py --Testing --source="${SOURCE}" --target="${TARGET}" --save_model_dir="${SAVE_MODEL_DIR}"