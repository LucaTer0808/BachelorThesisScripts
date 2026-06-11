import os
import glob
import argparse
import torch
import numpy as np
import cv2
import time
from PIL import Image
from tqdm import tqdm
from transformers import AutoImageProcessor, AutoModelForDepthEstimation

parser = argparse.ArgumentParser(description="Generiere Tiefenkarten aus RGB-Bildern mit Depth Anything v2 (Base-Modell).")
parser.add_argument("--source", type=str, required=True, help="Pfad zum Ordner mit den RGB-Bildern.")
parser.add_argument("--target", type=str, required=True, help="Pfad zum Ordner, in dem die generierten Tiefenkarten gespeichert werden sollen.")
args = parser.parse_args()


# --- CONFIGURATION ---
SOURCE_PATH = args.source
TARGET_PATH = args.target

# Mögliche Bildendungen
IMAGE_EXTENSIONS = ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.webp"]

# --- MODEL SETUP ---
print("Lade Depth Anything v2 (Base-Modell)...")
device = "cuda" if torch.cuda.is_available() else "cpu"

# Wir nutzen das offizielle HF-Repository von Apple / Depth Anything
model_id = "depth-anything/Depth-Anything-V2-Base-hf"
image_processor = AutoImageProcessor.from_pretrained(model_id)
model = AutoModelForDepthEstimation.from_pretrained(model_id).to(device)
model.eval()


# --- PROCESSING ---
def generate_depth_maps():
    image_paths = []
    for ext in IMAGE_EXTENSIONS:
        image_paths.extend(glob.glob(os.path.join(SOURCE_PATH, ext)))
    
    if not image_paths:
        print(f"Keine Bilder im Ordner '{SOURCE_PATH}' gefunden.")
        return
    
    number_images = len(image_paths)

    print(f"{number_images} Bilder gefunden. Starte Tiefenschätzung...")

    start_time = time.time()

    # 2. Schleife über alle Bilder mit Fortschrittsanzeige
    for img_path in tqdm(image_paths):
        try:
            # Bild laden
            raw_image = Image.open(img_path).convert("RGB")
            
            # Zielpfad berechnen (erhält die Unterordnerstruktur aufrecht)
            relative_path = os.path.relpath(img_path, SOURCE_PATH)
            # Tauscht die Dateiendung zu .png (wichtig für verlustfreie 8-Bit-Speicherung)
            base_name = os.path.splitext(relative_path)[0] + ".png" 
            out_path = os.path.join(TARGET_PATH, base_name)
            
            # Zielordner erstellen, falls er noch nicht existiert
            out_dir = os.path.dirname(out_path)
            if out_dir:
                os.makedirs(out_dir, exist_ok=True)

            # 3. Model Inference (Tiefenberechnung)
            inputs = image_processor(images=raw_image, return_tensors="pt").to(device)
            
            with torch.no_grad():
                outputs = model(**inputs)
                # Vorhersage auf die originale Bildgröße hochskalieren
                post_processed_output = image_processor.post_process_depth_estimation(
                    outputs,
                    target_sizes=[raw_image.size[::-1]],
                )
                # Tensor herausholen
                depth = post_processed_output[0]["predicted_depth"]
            
            # 4. Umwandlung in ein 1-Kanal 8-Bit Bild (0-255)
            depth_np = depth.cpu().numpy()
            
            # Min-Max Normalisierung auf den Bereich [0, 255]
            depth_min = depth_np.min()
            depth_max = depth_np.max()
            
            if depth_max > depth_min:
                depth_scaled = (depth_np - depth_min) / (depth_max - depth_min) * 255.0
            else:
                depth_scaled = np.zeros_like(depth_np)
                
            depth_8bit = depth_scaled.astype(np.uint8)

            # 5. Speichern als 1-Kanal Bild via OpenCV
            cv2.imwrite(out_path, depth_8bit)

        except Exception as e:
            print(f"\nFehler beim Verarbeiten von {img_path}: {e}")

    end_time = time.time()
    elapsed_time = end_time - start_time
    time_per_image = elapsed_time / number_images if number_images > 0 else 0

    log_file_path = TARGET_PATH + ".txt"
    with open(log_file_path, "w", encoding="utf-8") as log_file:
        log_file.write(f"Anzahl Bilder: {number_images}\n")
        log_file.write(f"Gesamte Verarbeitungszeit: {elapsed_time:.2f} Sekunden\n")
        log_file.write(f"Durchschnittliche Zeit pro Bild: {time_per_image:.2f} Sekunden\n")

if __name__ == "__main__":
    generate_depth_maps()
    print("Fertig! Alle Tiefenkarten wurden erzeugt.")
