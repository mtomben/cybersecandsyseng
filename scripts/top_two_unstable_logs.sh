#!/bin/bash

for file in ../logs/*.log
do
    if [ -f "$file" ]; then
        count=$(grep -c "ERROR" "$file")
        echo "$count $(basename "$file")"
    fi
done | sort -rn | head -n 2 | awk '{print $2 ": " $1 " errors"}'
