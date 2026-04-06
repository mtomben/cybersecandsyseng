#!/bin/bash


if [ -z "$1" ]; then
    echo "Error: No search pattern provided."
    echo "Usage: $0 <search_pattern> <file_path_pattern>"
    exit 1
fi


PATTERN=$1


shift

TOTAL_MATCHES=0

echo "Searching for '$PATTERN' in logs..."
echo "--------------------------------"

for FILE in "$@"; do
    if [ -f "$FILE" ]; then
        # Count matches in the current file
        COUNT=$(grep -c "$PATTERN" "$FILE")
        echo "File $FILE: $COUNT matches"
        
        # Add to the running total
        TOTAL_MATCHES=$((TOTAL_MATCHES + COUNT))
    else
        echo "Warning: $FILE not found, skipping."
    fi
done

echo "--------------------------------"
echo "TOTAL MATCHES ACROSS ALL LOGS: $TOTAL_MATCHES"
