from huggingface_hub import snapshot_download
import argparse
import os

args = argparse.ArgumentParser(description="Download a dataset from Hugging Face Hub.")
args.add_argument("--target", type=str, required=True, help="The target directory to download the dataset to.")
args.add_argument("--repo_id", type=str, required=True, help="The repository ID of the dataset on Hugging Face Hub.")

args = args.parse_args()

snapshot_download(
    repo_id=args.repo_id,
    local_dir=args.target,
    local_dir_use_symlinks=False
)