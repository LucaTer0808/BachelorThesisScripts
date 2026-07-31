import argparse
import os
import pandas as pd
from py_sod_metrics import Emeasure, Fmeasure, MAE, Smeasure, WeightedFmeasure
from tqdm import tqdm
import cv2
import warnings

warnings.filterwarnings("ignore")

parser = argparse.ArgumentParser(description="Evaluate a model on a dataset.")
parser.add_argument("--gt", type=str, required=True, help="Path to the ground truth file.")
parser.add_argument("--pred", type=str, required=True, help="Path to the predictions file.")

args = parser.parse_args()

# Metrics
eval_f = Fmeasure() # beta value is set to 0.3 by default
eval_mae = MAE()
eval_s = Smeasure() # default threshold is 0.5
eval_wf = WeightedFmeasure()
eval_em = Emeasure()

gt_files = sorted(f for f in os.listdir(args.gt) if f.endswith('.png') or f.endswith('.jpg') or f.endswith('.jpeg'))
pred_files = sorted(f for f in os.listdir(args.pred) if f.endswith('.png') or f.endswith('.jpg') or f.endswith('.jpeg'))

if not gt_files:
    raise ValueError("No ground truth files found in the specified directory.")
if not pred_files:
    raise ValueError("No prediction files found in the specified directory.")

pred_dict = {os.path.splitext(f)[0]: f for f in pred_files}

for gt_file in tqdm(gt_files):
    base_name = os.path.splitext(gt_file)[0]

    if base_name not in pred_dict:
        raise ValueError(f"Prediction for ground truth file '{gt_file}' not found in the predictions directory.")

    gt_path = os.path.join(args.gt, gt_file)
    pred_path = os.path.join(args.pred, pred_dict[base_name])

    gt_img = cv2.imread(gt_path, cv2.IMREAD_GRAYSCALE)
    pred_img = cv2.imread(pred_path, cv2.IMREAD_GRAYSCALE)

    if gt_img.shape != pred_img.shape:
        pred_img = cv2.resize(pred_img, (gt_img.shape[1], gt_img.shape[0]), interpolation=cv2.INTER_LINEAR)

    eval_f.step(pred_img, gt_img)
    eval_mae.step(pred_img, gt_img)
    eval_s.step(pred_img, gt_img)
    eval_wf.step(pred_img, gt_img)
    eval_em.step(pred_img, gt_img)

# Results
res_f = eval_f.get_results()
res_mae = eval_mae.get_results()
res_s = eval_s.get_results()
res_wf = eval_wf.get_results()
res_em = eval_em.get_results()

sm = res_s['sm']
max_fm = res_f['fm']['curve'].max()
adp_fm = res_f['fm']['adp']
wfm = res_wf['wfm']
adp_em = res_em['em']['adp']
mae = res_mae['mae']
precisions = res_f['pr']['p']
recalls = res_f['pr']['r']

parts = [p for p in args.pred.split('/') if p]
gt_parts = [p for p in args.gt.split('/') if p]

model_name = parts[4]
dataset_name = parts[5]

# --- 1. Evaluation Summary ---
results_summary = {
    "Model": [model_name],
    "Dataset": [dataset_name],
    "RGB or RGBD": [gt_parts[4]],
    "Sm": [round(sm, 4)],
    "maxFm": [round(max_fm, 4)],
    "adpFm": [round(adp_fm, 4)],
    "wFm": [round(wfm, 4)],
    "adpEm": [round(adp_em, 4)],
    "MAE": [round(mae, 4)],
}

df_summary = pd.DataFrame(results_summary)
output_csv_path = os.path.join(args.pred, "evaluation.csv")

if os.path.exists(output_csv_path):
    os.remove(output_csv_path)

df_summary.to_csv(output_csv_path, index=False, sep=";")


# --- 2. Hierarchische PR-Curve CSV ---
# Erstelle einen MultiIndex für die Spalten: (Modell, Datensatz, Metrik)
columns = pd.MultiIndex.from_tuples(
    [
        (model_name, dataset_name, "Precision"),
        (model_name, dataset_name, "Recall")
    ],
    names=["Model", "Dataset", "Metric"]
)

# Erstelle den Dataframe mit 256 Schwellenwerten als Index
df_pr = pd.DataFrame(
    data=list(zip(precisions, recalls)),
    index=pd.Index(range(256), name="Threshold"),
    columns=columns
)

pr_csv_path = os.path.join(args.pred, "prcurve_combined.csv")

if os.path.exists(pr_csv_path):
    os.remove(pr_csv_path)

df_pr.to_csv(pr_csv_path, sep=";")