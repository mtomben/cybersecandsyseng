
LOG_DIR="../logs"
OUTPUT_FILE="../reports/level_summary.txt"

echo "Counting log levels across all satellite logs..." > "$OUTPUT_FILE"
cut -d' ' -f3 "$LOG_DIR"/sat-*.log | sort | uniq -c | awk '{print $2 ": " $1 " occurrences"}' >> "$OUTPUT_FILE"

echo "Summary saved to $OUTPUT_FILE"
