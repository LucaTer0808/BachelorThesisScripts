import glob
import os
import pandas as pd

ROOT_DIR = "/scratch/tmp/lterfehr/model_results/"

# 1. Alle prcurve.csv in Unterordnern finden
pr_files = glob.glob(os.path.join(ROOT_DIR, "**", "prcurve.csv"), recursive=True)

df_list = []
for file_path in pr_files:
    # Ordnernamen für Modell und Datensatz aus dem Pfad extrahieren
    parts = [p for p in file_path.split(os.sep) if p]
    model_name = parts[-3]    # z. B. HFIL
    dataset_name = parts[-2]  # z. B. DUT-RGBD oder DUT-RGBD_gen_depth

    # Datei einlesen
    df = pd.read_csv(file_path, sep=";")

    # Falls der Index/Threshold noch als normale Spalte vorliegt:
    if "Threshold" in df.columns:
        df = df.set_index("Threshold")

    # Spalten zu MultiIndex (Model, Dataset, Metric) umbenennen
    df.columns = pd.MultiIndex.from_tuples([
        (model_name, dataset_name, "Precision"),
        (model_name, dataset_name, "Recall")
    ], names=["Model", "Dataset", "Metric"])

    df_list.append(df)

# Alle einzelnen Tabellen spaltenweise (axis=1) zusammenfügen
df_combined = pd.concat(df_list, axis=1)

# Als eine große CSV speichern
output_path = os.path.join(ROOT_DIR, "all_models_pr_curves.csv")

if os.path.exists(output_path):
    os.remove(output_path)

df_combined.to_csv(output_path, sep=";")

print(f"✅ Kombinierte Datei erfolgreich unter '{output_path}' gespeichert!")