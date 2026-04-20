#!/bin/bash

# Umbrales
CPU_LIMIT=50
ERR_LIMIT=10
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
# El archivo se guarda en la carpeta reports [cite: 217, 311]
REPORT_FILE="../reports/mission_runtime_security_report_$TIMESTAMP.txt"

# Recopilación de datos según el PDF [cite: 312, 313, 314, 315, 316, 317, 318, 319]
LOG_FILES_COUNT=$(ls ../logs/*.log | wc -l)
TOTAL_PROC=$(ps -e | wc -l)
UNAUTH_COUNT=$(./unauthorized_process_audit.sh | grep "TOTAL UNAUTHORIZED" | awk '{print $3}')
HIGH_CPU_COUNT=$(./resource_usage_detector.sh $CPU_LIMIT 100 | grep -c "WARNING")
TOTAL_ERRORS=$(grep -r "ERROR" ../logs/*.log | wc -l)
MOST_UNSTABLE=$(./log_anomaly_detector.sh $ERR_LIMIT | grep "Most unstable" | awk -F': ' '{print $2}' | awk '{print $1}')
TOP_CPU_NAME=$(ps -eo comm --sort=-%cpu | head -n 2 | tail -n 1)
FINAL_STATUS=$(./incident_classifier.sh $CPU_LIMIT $ERR_LIMIT)

{
    echo "MISSION RUNTIME SECURITY REPORT"
    echo "Generated at: $TIMESTAMP" [cite: 320, 326]
    echo "------------------------------"
    echo "Processed log files: $LOG_FILES_COUNT" [cite: 312, 327]
    echo "Active processes: $TOTAL_PROC" [cite: 313, 328]
    echo "Unauthorized processes: $UNAUTH_COUNT" [cite: 314, 329]
    echo "High CPU processes: $HIGH_CPU_COUNT" [cite: 315, 330]
    echo "ERROR entries: $TOTAL_ERRORS" [cite: 316, 331]
    echo "Most unstable log: $MOST_UNSTABLE" [cite: 317, 332]
    echo "Top CPU process: $TOP_CPU_NAME" [cite: 318, 333]
    echo "Incident classification: $FINAL_STATUS" [cite: 319, 334]
} > "$REPORT_FILE"

cat "$REPORT_FILE"
echo -e "\nReport saved to: $REPORT_FILE"
