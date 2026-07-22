import os
import argparse
from PIL import Image

parser = argparse.ArgumentParser()
parser.add_argument("--gt", type=str)
parser.add_argument("--target", type=str)

args = parser.parse_args()
gt_folder = args.gt
target_folder = args.target

valid_extensions = (".png", ".jpg", ".jpeg", ".bmp", ".tiff")

if not os.path.exists(gt_folder):
    print(f"Ground truth folder '{gt_folder}' does not exist.")
    exit(1)

for fname in os.listdir(gt_folder):
    if not fname.lower().endswith(valid_extensions):
        continue
    fname_without_ext = os.path.splitext(fname)[0]

    gt_file = os.path.join(gt_folder, fname)
    target_file = next((os.path.join(target_folder, f) for f in os.listdir(target_folder) if os.path.splitext(f)[0] == fname_without_ext), None)

    if not target_file:
        print(f"Target file for '{fname}' not found.")
        exit(1)

    with Image.open(gt_file) as gt_img, Image.open(target_file) as target_img:
        gt_size = gt_img.size
        target_size = target_img.size

        if gt_size != target_size:
            print(f"Size mismatch for '{fname}': Ground truth size {gt_size}, Target size {target_size}")
            exit(1)