
LOG_DIR="../logs"
OUTPUT_FILE="../reports/warn_timestamps.txt"



grep WARN "$LOG_DIR"/sat-*.log | cut -d' ' -f1,2 > "$OUTPUT_FILE"
