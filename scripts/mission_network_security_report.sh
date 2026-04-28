#!/bin/bash
# Task 10: Full Network Security Report
TS_FILE=$(date +%Y-%m-%d-%H-%M-%S)
TS_HUMAN=$(date "+%Y-%m-%d %H:%M:%S")
mkdir -p ../reports
OUT="../reports/mission_network_security_report-$TS_FILE.txt"

# Recolección de datos dinámica
LISTEN_N=$(./listening_service_audit.sh | grep "LISTENING SERVICE" | wc -l)
ESTAB_N=$(./established_connection_audit.sh | grep "ESTABLISHED CONNECTION" | wc -l)
EXPOSED_N=$(./external_port_exposure_audit.sh | grep "EXPOSED PORT" | wc -l)
SUSPICIOUS_N=$(./suspicious_remote_connection_audit.sh | grep "SUSPICIOUS CONNECTION" | wc -l)
TOP_PROC=$(ss -tnp state established | tail -n +2 | awk '{print $6}' | cut -d'"' -f2 | sort | uniq -c | sort -nr | head -n 1)
[ -z "$TOP_PROC" ] && TOP_PROC="NONE"

# Datos de Runtime (Lab 4)
HIGH_CPU=$(top -bn1 | awk 'NR>7 {if($9>80) print $0}' | wc -l)
LOG_ERRORS=$(grep -ri "ERROR" ../logs/ 2>/dev/null | wc -l)
CLASS=$(./network_incident_classifier.sh | grep "CLASIFICACIÓN:" | awk '{print $2}')

{
echo "=== MISSION NETWORK SECURITY REPORT ==="
echo "TIME: $TS_HUMAN"
echo ""
echo "[NETWORK STATE]"
echo "LISTENING SERVICES: $LISTEN_N"
echo "ESTABLISHED CONNECTIONS: $ESTAB_N"
echo "UNEXPECTED EXPOSED PORTS: $EXPOSED_N"
echo "SUSPICIOUS REMOTE CONNECTIONS: $SUSPICIOUS_N"
echo "TOP PROCESS BY ESTABLISHED CONNECTIONS: $TOP_PROC"
echo ""
echo "[RUNTIME AND LOGS]"
echo "HIGH CPU PROCESSES: $HIGH_CPU"
echo "TOTAL LOG ERRORS: $LOG_ERRORS"
echo ""
echo "[CLASSIFICATION]"
echo "FINAL CLASSIFICATION: $CLASS"
} > "$OUT"

echo "Reporte guardado en $OUT"
cat "$OUT"
