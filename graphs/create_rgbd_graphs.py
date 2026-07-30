import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import shutil

CSV_FILE_PATH = "/scratch/tmp/lterfehr/model_results/combined_evaluation.csv"
OUTPUT_DIR = "/scratch/tmp/lterfehr/model_results/plots_rgbd_only/"

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

# --- Nur RGBD-Datensätze behalten ---
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

        # --- Nur RGBD-Modelle behalten: "_no_depth"-Varianten (= RGB-only Modell
        # auf RGBD-Datensatz) rausfiltern ---
        full_names = [n for n in full_names if not n.endswith("_no_depth")]

        df_sub = df[df["Dataset"].isin(full_names)].copy()

        if df_sub.empty:
            continue

        # FARBGRUPPE & MODELLNAMEN ANPASSEN
        def process_row(row):
            ds_name = row["Dataset"]
            model_name = row["Model"]

            if ds_name.endswith("_gen_depth"):
                row["Color_Group"] = "RGBD with generated depth"
                row["Model_Display"] = f"{model_name} (gen_depth)"
            else:
                row["Color_Group"] = "RGBD"
                row["Model_Display"] = model_name

            return row

        df_sub = df_sub.apply(process_row, axis=1)

        # Sortierung nach dem Wert der Metrik
        df_sorted = df_sub.sort_values(by=metric, ascending=is_lower_better)

        ds_dir = os.path.join(OUTPUT_DIR, dataset)
        os.makedirs(ds_dir, exist_ok=True)

        plt.figure(figsize=(10, max(5, len(df_sorted) * 0.4)))

        # Farben zuweisen (kein RGB mehr, nur noch RGBD-Varianten)
        palette = {
            "RGBD": "#e74c3c",                        # ROT
            "RGBD with generated depth": "#66000f",    # DUNKELROT
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

        title_suffix = "(Niedriger ist besser)" if is_lower_better else "(Höher ist besser)"
        plt.title(f"Dataset: {dataset} (RGBD) — Metrik: {metric} {title_suffix}", fontsize=12, fontweight="bold")
        plt.xlabel(metric, fontsize=10)
        plt.ylabel("Modell", fontsize=10)

        plt.xlim(0, df_sorted[metric].max() * 1.15)
        plt.tight_layout()

        plot_path = os.path.join(ds_dir, f"{metric}_comparison.png")
        plt.savefig(plot_path, dpi=300)
        plt.close()

print("✅ Alle RGBD-Plots wurden erfolgreich im Zielordner gespeichert!")