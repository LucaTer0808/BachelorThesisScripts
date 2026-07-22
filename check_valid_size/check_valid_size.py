import os
import argparse
from PIL import Image

parser = argparse.ArgumentParser()
parser.add_argument("--gt", type=str)
parser.add_argument("--mask", type=str)
parser.add_argument("--depth", type=str, default=None)
parser.add_argument("--rgbd", action="store_true")

args = parser.parse_args()
gt_folder = args.gt
depth_folder = args.depth
mask_folder = args.mask
rgbd = args.rgbd

valid_extensions = (".png", ".jpg", ".jpeg", ".bmp", ".tiff")

if not os.path.exists(gt_folder):
    print(f"Ground truth folder '{gt_folder}' does not exist.")
    exit(1)

for fname in os.listdir(gt_folder):
    if not fname.lower().endswith(valid_extensions):
        continue
    fname_without_ext = os.path.splitext(fname)[0]

    gt_file = os.path.join(gt_folder, fname)
    mask_file = next((os.path.join(mask_folder, f) for f in os.listdir(mask_folder) if os.path.splitext(f)[0] == fname_without_ext), None)
    depth_file = next((os.path.join(depth_folder, f) for f in os.listdir(depth_folder) if os.path.splitext(f)[0] == fname_without_ext), None) if rgbd else None

    if not mask_file:
        print(f"Mask file for '{fname}' not found.")
        exit(1)

    with Image.open(gt_file) as gt_img, Image.open(mask_file) as mask_img:
        gt_size = gt_img.size
        mask_size = mask_img.size

        if gt_size != mask_size:
            print(f"Size mismatch for '{fname}': Ground truth size {gt_size}, Mask size {mask_size}")
            exit(1)

    if rgbd and depth_file:
        with Image.open(depth_file) as depth_img:
            depth_size = depth_img.size

            if gt_size != depth_size:
                print(f"Size mismatch for '{fname}': Ground truth size {gt_size}, Depth size {depth_size}")
                exit(1)