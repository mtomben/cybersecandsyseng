#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: you should said which document analize. Ejemplo: $0 '../logs/*.log'"
    exit 1
fi

PATTERN=$1
REPORT_FILE="../reports/mission_report.txt"

TOTAL_FILES=0
TOTAL_ENTRIES=0
INFO_COUNT=0
WARN_COUNT=0
ERROR_COUNT=0
MAX_ERRORS=-1
MOST_UNSTABLE_LOG=""

for file in $PATTERN
do
    if [ -f "$file" ]; then
        ((TOTAL_FILES++))

        current_entries=$(wc -l < "$file")
        TOTAL_ENTRIES=$((TOTAL_ENTRIES + current_entries))

        f_info=$(grep -c "INFO" "$file")
        f_warn=$(grep -c "WARN" "$file")
        f_error=$(grep -c "ERROR" "$file")

        INFO_COUNT=$((INFO_COUNT + f_info))
        WARN_COUNT=$((WARN_COUNT + f_warn))
        ERROR_COUNT=$((ERROR_COUNT + f_error))

        if [ "$f_error" -gt "$MAX_ERRORS" ]; then
            MAX_ERRORS=$f_error
            MOST_UNSTABLE_LOG=$(basename "$file")
        fi
    fi
done

{
    echo "MISSION REPORT"
    echo "Processed files: $TOTAL_FILES"
    echo "Total entries: $TOTAL_ENTRIES"
    echo "INFO: $INFO_COUNT"
    echo "WARN: $WARN_COUNT"
    echo "ERROR: $ERROR_COUNT"
    echo "Most unstable log: $MOST_UNSTABLE_LOG"
} > "$REPORT_FILE"

echo "Reporte generado en $REPORT_FILE"
