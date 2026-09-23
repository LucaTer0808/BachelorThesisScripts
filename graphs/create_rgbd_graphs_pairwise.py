import os
import shutil
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

CSV_FILE_PATH = "/scratch/tmp/lterfehr/model_results/combined_evaluation.csv"
OUTPUT_DIR = "/scratch/tmp/lterfehr/model_results/plots_rgbd_only_pairwise/"

if os.path.exists(OUTPUT_DIR):
    shutil.rmtree(OUTPUT_DIR)

os.makedirs(OUTPUT_DIR, exist_ok=True)

df = pd.read_csv(CSV_FILE_PATH, sep=";")

metrics = ["Sm", "maxFm", "adpFm", "wFm", "adpEm", "MAE"]

datasets = df["Dataset"].unique().tolist()
prefixes = [ds.split("_", 1)[0] for ds in datasets]

rgbd_bases = {
    "DUT-RGBD", "LFSD", "NJUD", "NLPR", "RGBD135",
    "SIP", "ReDWeb-S", "SSD", "STERE", "STEREO",
}

# --- Retain only RGB-D benchmark datasets ---
dataset_dict = {prefix: [] for prefix in prefixes if prefix in rgbd_bases}

for ds in datasets:
    prefix = ds.split("_", 1)[0]
    if prefix in dataset_dict:
        dataset_dict[prefix].append(ds.split("_", 1))

for metric in metrics:
    if metric not in df.columns:
        continue

    is_lower_better = (metric.upper() == "MAE")

    for dataset in dataset_dict.keys():
        entries = dataset_dict[dataset]
        full_names = ["_".join(entry) for entry in entries]

        # --- Filter out '_no_depth' variants ---
        full_names = [n for n in full_names if not n.endswith("_no_depth")]

        df_sub = df[df["Dataset"].isin(full_names)].copy()

        if df_sub.empty:
            continue

        # --- Format color group and display labels ---
        def process_row(row):
            ds_name = row["Dataset"]
            model_name = row["Model"]

            if ds_name.endswith("_gen_depth"):
                row["Color_Group"] = "RGB-D (Generated Depth)"
                row["Model_Display"] = f"{model_name} (gen_depth)"
            else:
                row["Color_Group"] = "RGB-D (Original Depth)"
                row["Model_Display"] = model_name

            # Base model name for grouped ordering
            row["Base_Model"] = model_name

            return row

        df_sub = df_sub.apply(process_row, axis=1)

        # ---------------------------------------------------------------------
        # Order by model pairs (Base_Model & Variant)
        # ---------------------------------------------------------------------
        # 1. Determine sort value per model group (e.g., best value of the pair)
        group_order = (
            df_sub.groupby("Base_Model")[metric]
            .agg("min" if is_lower_better else "max")
            .sort_values(ascending=is_lower_better)
            .index
        )

        # 2. Convert 'Base_Model' to categorical with fixed ordering
        df_sub["Base_Model"] = pd.Categorical(df_sub["Base_Model"], categories=group_order, ordered=True)

        # 3. Sort first by Base_Model, then by variant (Original first, gen_depth second)
        df_sorted = df_sub.sort_values(
            by=["Base_Model", "Color_Group"],
            ascending=[True, True]
        )
        # ---------------------------------------------------------------------

        ds_dir = os.path.join(OUTPUT_DIR, dataset)
        os.makedirs(ds_dir, exist_ok=True)

        plt.figure(figsize=(10, max(5, len(df_sorted) * 0.4)))

        # Color palette for pairwise comparison
        palette = {
            "RGB-D (Original Depth)": "#e74c3c",       # Red
            "RGB-D (Generated Depth)": "#66000f",      # Dark red
        }

        ax = sns.barplot(
            data=df_sorted,
            x=metric,
            y="Model_Display",
            hue="Color_Group",
            palette=palette,
            dodge=False,
            errorbar=None
        )

        # Add metric value labels to each bar
        for p in ax.patches:
            width = p.get_width()
            if width > 0:
                ax.annotate(
                    f"{width:.4f}",
                    (width + (width * 0.01), p.get_y() + p.get_height() / 2.),
                    ha="left", va="center",
                    fontsize=9,
                    xytext=(3, 0),
                    textcoords="offset points"
                )

        title_suffix = "(lower is better)" if is_lower_better else "(higher is better)"
        plt.title(f"Dataset: {dataset} (RGB-D) — Metric: {metric} {title_suffix}", fontsize=12, fontweight="bold")
        plt.xlabel(metric, fontsize=10)
        plt.ylabel("Model", fontsize=10)

        # Set clean legend title
        plt.legend(title="Depth Input", loc="lower right")

        plt.xlim(0, df_sorted[metric].max() * 1.15)
        plt.tight_layout()

        plot_path = os.path.join(ds_dir, f"{metric}_comparison.png")
        plt.savefig(plot_path, dpi=300)
        plt.close()

print("All RGB-D plots have been successfully generated and saved.")