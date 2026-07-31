import os
import pandas as pd
import matplotlib.pyplot as plt
import shutil

ROOT_DIR = "/scratch/tmp/lterfehr/model_results/"
COMBINED_CSV = os.path.join(ROOT_DIR, "all_models_pr_curves.csv")
OUTPUT_DIR = os.path.join(ROOT_DIR, "plots_pr_curves_per_model/")

if os.path.exists(OUTPUT_DIR):
    shutil.rmtree(OUTPUT_DIR)

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
    matching_ds = [ds for ds in all_datasets if ds.startswith(base_ds) and not ds.endswith("_no_depth")]

    if not matching_ds:
        continue

    # Alle Modelle für diesen Datensatz ermitteln
    models = sorted(list(set(col[0] for col in all_columns if col[1] in matching_ds)))

    for model in models:
        ds_gen = f"{base_ds}_gen_depth"

        has_rgbd = (model, base_ds, "Precision") in all_columns
        has_gen = (model, ds_gen, "Precision") in all_columns

        # Überspringen, falls für dieses Modell keine Daten vorliegen
        if not has_rgbd and not has_gen:
            continue

        plt.figure(figsize=(7, 6))
        plt.title(f"PR-Kurve: {model}\nDatensatz: {base_ds}", fontsize=12, fontweight="bold")

        # 1. Echte Tiefe (RGBD) -> Blau, durchgezogen
        if has_rgbd:
            p = df_all[(model, base_ds, "Precision")]
            r = df_all[(model, base_ds, "Recall")]
            plt.plot(r, p, label="Echte Tiefe (RGBD)", color="#1f77b4", linestyle="-", linewidth=2)

        # 2. Generierte Tiefe (gen_depth) -> Orange, gestrichelt
        if has_gen:
            p_gen = df_all[(model, ds_gen, "Precision")]
            r_gen = df_all[(model, ds_gen, "Recall")]
            plt.plot(r_gen, p_gen, label="Künstliche Tiefe (gen_depth)", color="#ff7f0e", linestyle="--", linewidth=2)

        plt.xlabel("Recall", fontsize=11)
        plt.ylabel("Precision", fontsize=11)
        plt.xlim([0.0, 1.0])
        plt.ylim([0.0, 1.05])
        plt.grid(True, linestyle=":", alpha=0.6)
        plt.legend(loc="lower left", fontsize=10)
        plt.tight_layout()

        # Dateiname bereinigen (Sonderzeichen im Modellnamen abfangen)
        safe_model_name = model.replace("/", "_").replace(" ", "_")
        plot_path = os.path.join(OUTPUT_DIR, f"{base_ds}_{safe_model_name}_PR_Curve.png")

        plt.savefig(plot_path, dpi=300)
        plt.close()

        print(f"📊 Plot gespeichert: {plot_path}")

print("✅ Fertig! Alle Einzel-PR-Plots wurden erstellt.")