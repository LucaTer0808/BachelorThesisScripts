import argparse
import os
import pandas as pd
from pysodmetrics import Emeasure, Fmeasure, MAE, Smeasure, WeightedFmeasure
from tqdm import tqdm
import cv2

parser = argparse.ArgumentParser(description="Evaluate a model on a dataset.")
parser.add_argument("--gt", type=str, required=True, help="Path to the ground truth file.")
parser.add_argument("--pred", type=str, required=True, help="Path to the predictions file.")

args = parser.parse_args()

# FMeasure
eval_f = Fmeasure() # beta value is set to 0.3 by default
eval_mae = MAE()
eval_s = Smeasure()
eval_wf = WeightedFmeasure()
eval_em = Emeasure()

gt_files = sorted(f for f in os.listdir(args.gt) if f.endswith('.png') or f.endswith('.jpg') or f.endswith('.jpeg'))
pred_files = sorted(f for f in os.listdir(args.pred) if f.endswith('.png') or f.endswith('.jpg') or f.endswith('.jpeg'))

if not gt_files:
    raise ValueError("No ground truth files found in the specified directory.")
if not pred_files:
    raise ValueError("No prediction files found in the specified directory.")

pred_dict = {os.path.splitext(f)[0]: f for f in pred_files}
print(f"Found {len(gt_files)} ground truth files and {len(pred_files)} prediction files.")

for gt_file in tqdm(gt_files):
    base_name = os.path.splitext(gt_file)[0]

    if base_name not in pred_dict:
        print(f"Ground truth file {gt_file} has no corresponding prediction file.")
        continue

    gt_path = os.path.join(args.gt, gt_file)
    pred_path = os.path.join(args.pred, pred_dict[base_name])

    gt_img = cv2.imread(gt_path, cv2.IMREAD_GRAYSCALE)
    pred_img = cv2.imread(pred_path, cv2.IMREAD_GRAYSCALE)

    if gt_img.shape != pred_img.shape:
        print(f"Shape mismatch for {gt_file}: ground truth shape {gt_img.shape}, prediction shape {pred_img.shape}. Resizing prediction to match ground truth.")
        pred_img = cv2.resize(pred_img, (gt_img.shape[1], gt_img.shape[0]), interpolation=cv2.INTER_LINEAR)

    eval_f.step(pred_img, gt_img)
    eval_mae.step(pred_img, gt_img)
    eval_s.step(pred_img, gt_img)
    eval_wf.step(pred_img, gt_img)
    eval_em.step(pred_img, gt_img)

# results
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

results_summary = {
    "SM" :[round(sm, 4)],
    "maxFM" :[round(max_fm, 4)],
    "adpFM" :[round(adp_fm, 4)],
    "wFM" :[round(wfm, 4)],
    "adpEM" :[round(adp_em, 4)],
    "MAE" :[round(mae, 4)],
    "Precisions" :[round(precisions, 4)],
    "Recalls" :[round(recalls, 4)]
}

results_summary = {
    "Dataset_Path": [args.gt],
    "Prediction_Path": [args.pred],
    "Sm": [round(sm, 4)],
    "maxFm": [round(max_fm, 4)],
    "adpFm": [round(adp_fm, 4)],
    "wFm": [round(wfm, 4)],
    "adpEm": [round(adp_em, 4)],
    "MAE": [round(mae, 4)],
}

df_summary = pd.DataFrame(results_summary)
output_csv_path = os.path.join(args.pred, "evaluation.csv")
df_summary.to_csv(output_csv_path, index=False, sep=";")

print(f"\n[INFO] Ergebnisse wurden gespeichert unter:\n{output_csv_path}")


pr_curve_data = {
    "Threshold": list(range(256)),
    "Precision": precisions,
    "Recall": recalls,
}
df_pr = pd.DataFrame(pr_curve_data)
pr_csv_path = os.path.join(args.pred, "pr_curve_data.csv")
df_pr.to_csv(pr_csv_path, index=False, sep=";")

print(f"[INFO] PR-Kurvendaten gespeichert unter:\n{pr_csv_path}")
