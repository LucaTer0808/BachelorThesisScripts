import os
import pandas as pd
import matplotlib.pyplot as plt

ROOT_DIR = "/scratch/tmp/lterfehr/model_results/"
COMBINED_CSV = os.path.join(ROOT_DIR, "all_models_pr_curves.csv")
OUTPUT_DIR = os.path.join(ROOT_DIR, "plots_pr_curves/")

os.makedirs(OUTPUT_DIR, exist_ok=True)

# Grosse CSV mit 3-stufigem Header einlesen
df_all = pd.read_csv(COMBINED_CSV, sep=";", header=[0, 1, 2], index_col=0)

RGBD_BASES = [
    "DUT-RGBD", "LFSD", "NJUD", "NLPR", "RGBD135",
    "SIP", "ReDWeb-S", "SSD", "STERE", "STEREO"
]

all_columns = df_all.columns
all_datasets = set(col[1] for col in all_columns)

for base_ds in RGBD_BASES:
    # Finde z.B. "DUT-RGBD" und "DUT-RGBD_gen_depth"
    matching_ds = [ds for ds in all_datasets if ds.startswith(base_ds) and not ds.endswith("_no_depth")]

    if not matching_ds:
        continue

    plt.figure(figsize=(9, 7))
    plt.title(f"PR-Kurven — Datensatz: {base_ds}", fontsize=13, fontweight="bold")

    # Alle Modelle für diesen Datensatz ermitteln
    models = sorted(list(set(col[0] for col in all_columns if col[1] in matching_ds)))
    colors = plt.cm.tab10.colors

    for idx, model in enumerate(models):
        color = colors[idx % len(colors)]

        # 1. Echte Tiefe (RGBD) -> Durchgezogene Linie
        if (model, base_ds, "Precision") in all_columns:
            p = df_all[(model, base_ds, "Precision")]
            r = df_all[(model, base_ds, "Recall")]
            plt.plot(r, p, label=f"{model} (RGBD)", color=color, linestyle="-", linewidth=2)

        # 2. Generierte Tiefe (gen_depth) -> Gestrichelte Linie
        ds_gen = f"{base_ds}_gen_depth"
        if (model, ds_gen, "Precision") in all_columns:
            p_gen = df_all[(model, ds_gen, "Precision")]
            r_gen = df_all[(model, ds_gen, "Recall")]
            plt.plot(r_gen, p_gen, label=f"{model} (gen_depth)", color=color, linestyle="--", linewidth=1.8, alpha=0.85)

    plt.xlabel("Recall", fontsize=11)
    plt.ylabel("Precision", fontsize=11)
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.grid(True, linestyle=":", alpha=0.6)
    plt.legend(bbox_to_anchor=(1.04, 1), loc="upper left", fontsize=9)
    plt.tight_layout()

    plot_path = os.path.join(OUTPUT_DIR, f"{base_ds}_PR_Curve.png")

    if os.path.exists(plot_path):
        os.remove(plot_path)

    plt.savefig(plot_path, dpi=300)
    plt.close()

    print(f"📊 Plot gespeichert: {plot_path}")

print("✅ Fertig! Alle PR-Plots wurden erstellt.")