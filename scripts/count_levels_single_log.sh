#!/bin/bash
# Task P5: Counting Log Levels in a Single Log File

echo "Summary"
cut -d' ' -f3 ../logs/sat-001.log | sort | uniq -c
LOG_FILE="../logs/sat-001.log"

cut -d' ' -f3 "$LOG_FILE" | sort | uniq -c | awk '{print $2 ": " $1 " occurrences"}'
