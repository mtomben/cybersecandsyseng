#!/bin/bash

TOTAL_NON_INFO=0

echo "EXTRACTING NON-INFO EVENTS..."
echo "----------------------------"

for file in ../logs/*.log
do
    if [ -f "$file" ]; then
        # Extraemos las líneas que NO contienen "INFO"
        # -v invierte la búsqueda
        grep -v "INFO" "$file"
        
        # Contamos cuántas líneas NO son INFO en este archivo
        count=$(grep -v -c "INFO" "$file")
        TOTAL_NON_INFO=$((TOTAL_NON_INFO + count))
    fi
done

echo "----------------------------"
echo "Total non-info entries found: $TOTAL_NON_INFO"
