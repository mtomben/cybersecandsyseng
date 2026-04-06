#!/bin/bash

if [ -z "$1" ]; then
    echo "Error:You should pgive a valid argument as: INFO, WARN o ERROR)" 
    exit 1
fi

# Guardamos el argumento en una variable con nombre claro
PATTERN=$1 
REPORT_FILE="../reports/pattern_report.txt" 

echo "PATTERN REPORT: $PATTERN" > "$REPORT_FILE" 

for file in ../logs/*.log
do
    
    filename=$(basename "$file")
    

    count=$(grep -c "$PATTERN" "$file") 
    echo "$filename: $count" >> "$REPORT_FILE"
done

echo "Report generate: $REPORT_FILE"
