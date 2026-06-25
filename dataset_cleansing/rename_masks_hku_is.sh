#!/bin/bash

cd "/scratch/tmp/lterfehr/datasets/rgbd/HKU-IS_gen_depth/test_masks"

echo "=== Starte Umbenennung der Masken im Ordner: $(pwd) ==="
for file in maske_*; do
    # Sicherstellen, dass die Datei wirklich existiert (falls keine Treffer da sind)
    [ -e "$file" ] || continue
    
    # Ersetze das Präfix 'maske_' durch 'bild_'
    new_name="bild_${file#maske_}"
    
    echo "Umbenenne: $file -> $new_name"
    mv "$file" "$new_name"
done

cd "/scratch/tmp/lterfehr/datasets/rgb/HKU-IS/test_masks"

echo "=== Starte Umbenennung im Ordner: $(pwd) ==="
for file in maske_*; do
    # Sicherstellen, dass die Datei wirklich existiert (falls keine Treffer da sind)
    [ -e "$file" ] || continue
    
    # Ersetze das Präfix 'maske_' durch 'bild_'
    new_name="bild_${file#maske_}"
    
    echo "Umbenenne: $file -> $new_name"
    mv "$file" "$new_name"
done

echo "Umbenennung abgeschlossen!"