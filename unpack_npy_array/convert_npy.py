import os
import argparse
import numpy as np
from PIL import Image
from tqdm import tqdm

def convert_npy_to_images(npy_path, output_dir):
    # 1. .npy Datei laden
    print(f"Lade Datensatz: {npy_path}...")
    data = np.load(npy_path)
    
    print(f"Shape des Arrays: {data.shape}")
    # Erwartet z.B. (N, H, W, C) oder (N, C, H, W) oder (N, H, W)
    
    os.makedirs(output_dir, exist_ok=True)
    
    # 2. Dimensionen normalisieren, falls Kanäle vorne liegen (PyTorch-Style: N, C, H, W)
    # Wir brauchen für Pillow am Ende (H, W, C) oder (H, W)
    if data.ndim == 4:
        # Wenn die 2. Dimension (Index 1) 1 oder 3 ist, liegen die Kanäle wahrscheinlich vorne
        if data.shape[1] in [1, 3] and data.shape[3] not in [1, 3]:
            print("Erkenne PyTorch-Format (N, C, H, W). Konvertiere zu (N, H, W, C)...")
            data = np.transpose(data, (0, 2, 3, 1))
            
    # 3. Iteration über alle Bilder im Datensatz
    for idx in tqdm(range(len(data)), desc="Speichere Bilder"):
        img_array = data[idx]
        
        # Falls Werte als Floats zwischen 0 und 1 liegen, auf 0-255 hochskalieren
        if img_array.dtype == np.float32 or img_array.dtype == np.float64:
            if img_array.max() <= 1.0:
                img_array = (img_array * 255).astype(np.uint8)
            else:
                img_array = img_array.astype(np.uint8)
                
        # Dimensionen für Single-Channel (Masken/Tiefe) bereinigen, falls (H, W, 1)
        if img_array.ndim == 3 and img_array.shape[-1] == 1:
            img_array = img_array.squeeze(-1)
            
        # 4. Als Bild in Originalauflösung konvertieren und speichern
        img = Image.fromarray(img_array)
        
        # Generiert Namen wie maske_0000.png, maske_0001.png etc.
        save_path = os.path.join(output_dir, f"maske_{idx:04d}.png")
        img.save(save_path)

    print(f"\nErfolgreich {len(data)} Bilder in '{output_dir}' gespeichert!")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Konvertiere .npy Datensatz in PNG Bilder")
    parser.add_argument("--npy", type=str, required=True, help="Pfad zur .npy Datei")
    parser.add_argument("--out", type=str, required=True, help="Zielordner für die Bilder")
    
    args = parser.parse_args()
    convert_npy_to_images(args.npy, args.out)