#!/bin/bash

TEMP_LEVELS="levels.tmp"
> "$TEMP_LEVELS"

for file in ../logs/*.log
do
    if [ -f "$file" ]; then
        # Extraemos la columna 3 (donde suele estar INFO, WARN, ERROR)
        awk '{print $3}' "$file" >> "$TEMP_LEVELS"
    fi
done

echo "GLOBAL EVENT DISTRIBUTION"
echo "-------------------------"

# Contamos las repeticiones de cada nivel encontrado
sort "$TEMP_LEVELS" | uniq -c | awk '{print $2 ": " $1}'

rm "$TEMP_LEVELS"
