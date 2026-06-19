#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuexpress
#SBATCH --gres=gpu:1

#SBATCH --job-name=ustdnet_on_lfsd_no_depth
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lterfehr@uni-muenster.de
#SBATCH --export=ALL

module --force purge
module load palma/2022a
module load GCC/11.3.0
module load GCCcore/11.3.0
module load Python/3.10.4
module load CUDA/11.7.0

WORKDIR="/scratch/tmp/lterfehr/BachelorThesisScripts/stdnet-test"
MODELDIR="/scratch/tmp/lterfehr/models/stdnet"
DATADIR="/scratch/tmp/lterfehr/models/stdnet/data"
TESTDATA="data"
VENV="${MODELDIR}/.venv"

SOURCE="/scratch/tmp/lterfehr/datasets/rgb/LFSD_no_depth/test_images"
GT="/scratch/tmp/lterfehr/datasets/rgb/LFSD_no_depth/test_masks"

OUTDIR="/scratch/tmp/lterfehr/model_results/stdnet/LFSD_no_depth"

size=384
exp="sdneta_from_pretrained"

cd "${MODELDIR}"

nvidia-smi

if [ -d "${VENV}" ]; then
    echo "=== Alte venv gefunden. Lösche Verzeichnis === "
    rm -rf "${VENV}"
fi

echo "=== Erstelle venv komplett neu ==="
python3 -m venv "${VENV}"
source "${VENV}/bin/activate"

echo "=== Installiere requirements.txt ==="
pip install --quiet --upgrade pip
pip install --quiet -r "${MODELDIR}/requirements.txt"

echo "=== Setup der virtuellen Umgebung abgeschlossen ==="

echo "=== Lösche Zielordner für Idempotenz ==="

if [ -d "${OUTDIR}" ]; then
    echo "=== ${OUTDIR} existiert bereits. Lösche es für Idempotenz ==="
    rm -rf "${OUTDIR}"
fi

echo "=== Ordner an Ort und stelle kopieren ==="

rm -rf "${DATADIR}/${TESTDATA}"
mkdir -p "${DATADIR}/${TESTDATA}/images"
mkdir -p "${DATADIR}/${TESTDATA}/GT"

cp -r "${SOURCE}/." "${DATADIR}/${TESTDATA}/images/"
cp -r "${GT}/." "${DATADIR}/${TESTDATA}/GT/"

echo "=== Starte STDNet ... ==="

python $MODELDIR/generate_salmaps_sod.py --model sdneta --inference-config baseline --train-config sdnet-a --bn --gpu 0 -j 4 --datadir ${DATADIR} --testdata ${TESTDATA} --savedir results/${exp} --evaluate checkpoints/${exp}.pth --size ${size}

echo "=== Ergebnisse herunterladen ... ==="

mkdir -p "${OUTDIR}"
cp -r "${MODELDIR}/results/${exp}/${TESTDATA}/." "${OUTDIR}"

echo "=== Bereinige directory ==="

rm -rf "${DATADIR}/${TESTDATA}"
rm -rf "${MODELDIR}/results/${exp}"

echo "Job beendet: $(date)"
