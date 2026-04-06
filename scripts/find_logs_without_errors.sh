#!/bin/bash

echo "Archivos de log sin errores detectados:"
echo "---------------------------------------"

for file in ../logs/*.log
do
    if [ -f "$file" ]; then
        count=$(grep -c "ERROR" "$file")
        
        if [ "$count" -eq 0 ]; then
            basename "$file"
        fi
    fi
done
