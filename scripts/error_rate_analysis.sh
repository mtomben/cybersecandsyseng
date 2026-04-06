#!/bin/bash

max_rate=0
worst_sat=""

for file in ../logs/sat-*.log
do
    if [ -f "$file" ]; then
        total=$(wc -l < "$file")
        errors=$(grep -c "ERROR" "$file")
        
        if [ "$total" -gt 0 ]; then
            # Calculamos la tasa con 4 decimales usando bc
            rate=$(echo "scale=4; $errors / $total" | bc)
            
            echo "$(basename "$file"): $rate ($errors errores de $total entradas)"
            
            # Comparamos decimales usando bc (devuelve 1 si es cierto)
            if [ "$(echo "$rate > $max_rate" | bc)" -eq 1 ]; then
                max_rate=$rate
                worst_sat=$(basename "$file")
            fi
        fi
    fi
done

echo "------------------------------------------------"
echo "Satélite con mayor tasa de error: $worst_sat ($max_rate)"
