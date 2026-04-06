#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: No log file path provided."
    echo "Usage: $0 <file_path> <search_pattern>"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Error: No search pattern provided."
    echo "Usage: $0 $1 <search_pattern>"
    exit 1
fi

LOG_FILE=$1
PATTERN=$2

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File '$LOG_FILE' not found."
    exit 1
fi
MATCH_COUNT=$(grep -c "$PATTERN" "$LOG_FILE")

echo "Analysis complete: Found $MATCH_COUNT occurrences of '$PATTERN' in $LOG_FILE."
