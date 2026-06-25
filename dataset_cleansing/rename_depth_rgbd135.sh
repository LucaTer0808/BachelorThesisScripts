#!/bin/bash

# Falls du das Skript von außerhalb ausführst, kannst du hier den Pfad eintragen.
# '.' bedeutet: der aktuelle Ordner, in dem das Skript liegt.
TARGET_DIR="/scratch/tmp/lterfehr/datasets/rgbd/RGBD135/test_depth"

echo "=== Starte Umbenennung im Ordner: ${TARGET_DIR} ==="

# Schleife über alle Dateien, die auf _depth.png enden
for file in "${TARGET_DIR}"/*_depth.png; do
    
    # Sicherstellen, dass überhaupt passende Dateien existieren
    [ -e "$file" ] || continue
    
    # Den neuen Dateinamen generieren (ersetzt "_depth.png" durch ".png")
    new_file="${file/_depth.png/.png}"
    
    # Datei umbenennen
    mv "$file" "$new_file"
    echo "Umgewandelt: $(basename "$file") -> $(basename "$new_file")"
done

echo "=== Fertig! Alle Dateien wurden bereinigt. ==="
