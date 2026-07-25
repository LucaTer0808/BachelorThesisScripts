import glob
import pandas as pd

SEARCH_PATTERN = "/scratch/tmp/lterfehr/model_results/**/evaluation.csv"
OUTPUT_CSV_PATH = "/scratch/tmp/lterfehr/model_results/combined_evaluation.csv"

csv_files = sorted(glob.glob(SEARCH_PATTERN, recursive=True))

df_list = []

for file in csv_files:
    df = pd.read_csv(file, sep=";")
    df_list.append(df)

if df_list:
    combined_df = pd.concat(df_list, ignore_index=True)

    if "Model" in combined_df.columns and "Dataset" in combined_df.columns:
        combined_df = combined_df.sort_values(by=["Model", "Dataset"])

    combined_df.to_csv(OUTPUT_CSV_PATH, index=False, sep=";")

else:
    print("No CSV files found matching the search pattern.")