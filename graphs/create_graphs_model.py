import os
import shutil
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

CSV_FILE_PATH = "/scratch/tmp/lterfehr/model_results/combined_evaluation.csv"
OUTPUT_DIR = "/scratch/tmp/lterfehr/model_results/plots_per_model_pairwise/"

if os.path.exists(OUTPUT_DIR):
    shutil.rmtree(OUTPUT_DIR)

os.makedirs(OUTPUT_DIR, exist_ok=True)

df = pd.read_csv(CSV_FILE_PATH, sep=";")

metrics = ["Sm", "maxFm", "adpFm", "wFm", "adpEm", "MAE"]

# STERE wurde entfernt, STEREO bleibt erhalten
rgbd_bases = {
    "DUT-RGBD",
    "LFSD",
    "NJUD",
    "NLPR",
    "RGBD135",
    "SIP",
    "ReDWeb-S",
    "SSD",
    "STEREO",
}

# Nach Länge absteigend sortieren, damit längere Namen zuerst geprüft werden
sorted_bases = sorted(rgbd_bases, key=len, reverse=True)


# Parse dataset names and clean prefixes
def parse_dataset_info(ds_name):
    # Exclude RGB-only / no-depth variants
    if ds_name.endswith("_no_depth"):
        return None, None

    is_gen = False
    base_name = ds_name

    if ds_name.endswith("_gen_depth"):
        base_name = ds_name.replace("_gen_depth", "")
        is_gen = True

    # Check prefix against defined RGB-D benchmark bases
    matched_base = None
    for b in sorted_bases:
        if base_name == b or base_name.startswith(b + "_"):
            matched_base = b
            break

    if not matched_base:
        return None, None

    depth_type = "RGB-D (Generated Depth)" if is_gen else "RGB-D (Original Depth)"
    return matched_base, depth_type


parsed = df["Dataset"].apply(parse_dataset_info)
df["Clean_Dataset"] = [p[0] for p in parsed]
df["Depth_Type"] = [p[1] for p in parsed]

# Keep only valid RGB-D benchmark entries
df_rgbd = df.dropna(subset=["Clean_Dataset", "Depth_Type"]).copy()

palette = {
    "RGB-D (Original Depth)": "#e74c3c",       # Red
    "RGB-D (Generated Depth)": "#66000f",      # Dark Red (Depth Anything V2)
}

models = df_rgbd["Model"].unique().tolist()

for model in models:
    df_model = df_rgbd[df_rgbd["Model"] == model].copy()
    if df_model.empty:
        continue

    model_dir = os.path.join(OUTPUT_DIR, model)
    os.makedirs(model_dir, exist_ok=True)

    for metric in metrics:
        if metric not in df_model.columns:
            continue

        is_lower_better = metric.upper() == "MAE"

        # Sort datasets pairwise based on best performance within each pair
        agg_func = "min" if is_lower_better else "max"
        dataset_order = (
            df_model.groupby("Clean_Dataset")[metric]
            .agg(agg_func)
            .sort_values(ascending=is_lower_better)
            .index.tolist()
        )

        plt.figure(figsize=(10, max(5, len(dataset_order) * 0.6)))

        # Grouped horizontal bar chart
        ax = sns.barplot(
            data=df_model,
            y="Clean_Dataset",
            x=metric,
            hue="Depth_Type",
            hue_order=["RGB-D (Original Depth)", "RGB-D (Generated Depth)"],
            order=dataset_order,
            palette=palette,
            dodge=True,
            errorbar=None,
        )

        # Annotate exact values at the end of each bar
        for p in ax.patches:
            width = p.get_width()
            if pd.notna(width) and width > 0:
                ax.annotate(
                    f"{width:.4f}",
                    (width, p.get_y() + p.get_height() / 2.0),
                    ha="left",
                    va="center",
                    fontsize=8,
                    xytext=(4, 0),
                    textcoords="offset points",
                )

        title_suffix = "(lower is better)" if is_lower_better else "(higher is better)"
        plt.title(
            f"Model: {model} — Metric: {metric} {title_suffix}",
            fontsize=12,
            fontweight="bold",
        )
        plt.xlabel(metric, fontsize=10)
        plt.ylabel("Dataset", fontsize=10)
        plt.legend(title="Depth Input", loc="lower right")

        max_val = df_model[metric].max()
        if pd.notna(max_val) and max_val > 0:
            plt.xlim(0, max_val * 1.18)

        plt.tight_layout()

        plot_path = os.path.join(model_dir, f"{metric}_comparison.png")
        plt.savefig(plot_path, dpi=300)
        plt.close()

print("All model-specific comparison plots successfully saved in English.")