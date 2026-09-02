import argparse
import os
from pathlib import Path
from PIL import Image

arparse = argparse.ArgumentParser(
    description="Überprüft die Bildgrößen in einem Ordner und gibt die Anzahl der Bilder mit unterschiedlichen Größen aus."
)
arparse.add_argument(
    "--folder_1", type=str, required=True, help="Pfad zum ersten Ordner mit Bildern."
)
arparse.add_argument(
    "--folder_2", type=str, required=True, help="Pfad zum zweiten Ordner mit Bildern."
)
args = arparse.parse_args()

folder_1 = Path(args.folder_1)
folder_2 = Path(args.folder_2)

if not folder_1.exists():
    print(f"Der Ordner {folder_1} existiert nicht.")
    exit(1)

if not folder_2.exists():
    print(f"Der Ordner {folder_2} existiert nicht.")
    exit(1)

# Unterstützte Dateiendungen
EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp", ".tif", ".tiff"}

# Index für folder_2 aufbauen (Mapping: Dateiname ohne Endung -> Dateipfad)
files_in_folder_2 = {}
for p in folder_2.iterdir():
    if p.is_file() and p.suffix.lower() in EXTENSIONS:
        files_in_folder_2[p.stem] = p

mismatches = []
missing_in_folder_2 = []
read_errors = []
compared_count = 0

# folder_1 durchlaufen und mit folder_2 abgleichen
for p1 in sorted(folder_1.iterdir()):
    if not p1.is_file() or p1.suffix.lower() not in EXTENSIONS:
        continue

    stem = p1.stem
    if stem not in files_in_folder_2:
        missing_in_folder_2.append(p1.name)
        continue

    p2 = files_in_folder_2[stem]
    compared_count += 1

    try:
        # Image.open liest nur den Header (Höhe/Breite), nicht das ganze Bild in den RAM
        with Image.open(p1) as img1, Image.open(p2) as img2:
            size1 = img1.size  # (Breite, Höhe)
            size2 = img2.size

            if size1 != size2:
                mismatches.append({
                    "stem": stem,
                    "file1": p1.name,
                    "size1": size1,
                    "file2": p2.name,
                    "size2": size2
                })
    except Exception as e:
        read_errors.append((p1.name, p2.name, str(e)))

# Auswertung
print("\n" + "=" * 60)
print("ERGEBNIS DES GRÖSSENVERGLEICHS")
print("=" * 60)
print(f"Erfolgreich verglichene Paare:     {compared_count}")
print(f"Paare mit abweichender Auflösung: {len(mismatches)}")
print(f"Fehlende Entsprechungen in Ordner 2: {len(missing_in_folder_2)}")
if read_errors:
    print(f"Lesefehler:                         {len(read_errors)}")
print("=" * 60)

if mismatches:
    print("\nAbweichungen (Breite x Höhe):")
    for m in mismatches:
        print(f"  - {m['file1']} {m['size1']}  vs  {m['file2']} {m['size2']}")

if missing_in_folder_2:
    print("\nErste fehlende Gegenstücke in Ordner 2 (max. 5):")
    for name in missing_in_folder_2[:5]:
        print(f"  - {name}")