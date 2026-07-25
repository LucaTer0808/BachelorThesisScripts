import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import shutil

CSV_FILE_PATH = "/scratch/tmp/lterfehr/model_results/combined_evaluation.csv"
OUTPUT_DIR = "/scratch/tmp/lterfehr/model_results/plots/"

if os.path.exists(OUTPUT_DIR):
    shutil.rmtree(OUTPUT_DIR)
    os.makedirs(OUTPUT_DIR, exist_ok=False)

df = pd.read_csv(CSV_FILE_PATH, sep=";")

metrics = ["Sm", "maxFm", "adpFm", "wFm", "adpEm", "MAE"]

datasets = df["Dataset"].unique().tolist()
prefixes = [ds.split("_", 1)[0] for ds in datasets]

dataset_dict = {prefix: [] for prefix in prefixes}
rgb_dict = {prefix: "RGB" for prefix in prefixes}

rgbd_bases = {
    "DUT-RGBD", "LFSD", "NJUD", "NLPR", "RGBD135", 
    "SIP", "ReDWeb-S", "SSD", "STERE", "STEREO",
}

rgb_dict = {prefix: ("RGBD" if prefix in rgbd_bases else "RGB") for prefix in prefixes}

for ds in datasets:
    prefix = ds.split("_", 1)[0]
    dataset_dict[prefix].append(ds.split("_", 1))


for metric in metrics:
    # Überprüfen, ob die Metrik überhaupt in der CSV vorkommt
    if metric not in df.columns:
        continue

    # MAE ist besser, wenn kleiner – andere Metriken besser, wenn größer
    is_lower_better = (metric.upper() == "MAE")

    for dataset in dataset_dict.keys():

        rgb_or_rgbd = rgb_dict[dataset]
        entries = dataset_dict[dataset]

        # 1. ALLE vollständigen Datensatz-Namen für diese Basis rekonstruieren
        # Beispiel: ['ReDWeb-S_gen_depth', 'ReDWeb-S_no_depth']
        full_names = ["_".join(entry) for entry in entries]

        # 2. ZUGRIFF AUF DIE CSV-WERTE:
        # Wir filtern alle Zeilen aus 'df', deren 'Dataset' in unserer Liste vorkommt
        df_sub = df[df["Dataset"].isin(full_names)].copy()

        # Falls für diesen Datensatz keine Daten existieren -> überspringen
        if df_sub.empty:
            continue

        # 3. ZUSATZ-SPALTE FÜR DIE FARBEN ANLEGEN:
        # Wir definieren für jede Zeile, ob sie Blau (RGB / no_depth) oder Rot (RGBD) wird
        def get_color_group(ds_name):
            if rgb_or_rgbd == "RGBD" and ds_name.endswith("_no_depth"):
                return "RGB"
            elif rgb_or_rgbd == "RGBD":
                return "RGBD"
            elif rgb_or_rgbd == "RGB" and ds_name.endswith("_gen_depth"):
                return "RGBD"
            else:
                return "RGB"

        df_sub["Color_Group"] = df_sub["Dataset"].apply(get_color_group)

        # 4. DATEN NACH DEN WERATEN DER METRIK SORTIEREN
        df_sorted = df_sub.sort_values(by=metric, ascending=is_lower_better)

        # --- AB HIER WIRD GEPLOTTE ---
        
        # Ordner für diesen Datensatz anlegen
        ds_dir = os.path.join(OUTPUT_DIR, dataset)
        os.makedirs(ds_dir, exist_ok=True)

        plt.figure(figsize=(10, max(5, len(df_sorted) * 0.4)))

        # Farben zuweisen
        palette = {
            "RGB": "#3498db",    # BLAU
            "RGBD": "#e74c3c"  # ROT
        }

        # Balkendiagramm mit Seaborn
        ax = sns.barplot(
            data=df_sorted,
            x=metric,            # Greift auf die Werte der Metrik-Spalte zu
            y="Model",           # Greift auf die Modellnamen-Spalte zu
            hue="Color_Group",   # Färbt nach RGB / RGBD
            palette=palette,
            dodge=False          # Setzt Balken untereinander statt nebeneinander
        )

        # Werte direkt an die Balken schreiben
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
        plt.title(f"Dataset: {dataset} ({rgb_or_rgbd}) — Metrik: {metric} {title_suffix}", fontsize=12, fontweight="bold")
        plt.xlabel(metric, fontsize=10)
        plt.ylabel("Modell", fontsize=10)

        plt.xlim(0, df_sorted[metric].max() * 1.15)
        plt.tight_layout()

        # Bild im jeweiligen Ordner speichern
        plot_path = os.path.join(ds_dir, f"{metric}_comparison.png")
        plt.savefig(plot_path, dpi=300)
        plt.close()

print("✅ Alle Plots wurden erfolgreich im Zielordner gespeichert!")
