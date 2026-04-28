#!/bin/bash
# Task 9: Network Snapshot
TS=$(date "+%Y-%m-%d %H:%M:%S")
LISTEN_N=$(./listening_service_audit.sh | grep "LISTENING SERVICE" | wc -l)
ESTAB_N=$(./established_connection_audit.sh | grep "ESTABLISHED CONNECTION" | wc -l)
EXPOSED_N=$(./external_port_exposure_audit.sh | grep "EXPOSED PORT" | wc -l)
SUSPICIOUS_N=$(./suspicious_remote_connection_audit.sh | grep "SUSPICIOUS CONNECTION" | wc -l)

# Proceso con más conexiones (lógica dinámica)
TOP_PROC=$(ss -tnp state established | tail -n +2 | awk '{print $6}' | cut -d'"' -f2 | sort | uniq -c | sort -nr | head -n 1)
[ -z "$TOP_PROC" ] && TOP_PROC="NONE (0)"

CLASS=$(./network_incident_classifier.sh | grep "CLASIFICACIÓN:" | awk '{print $2}')

echo "=== NETWORK SNAPSHOT ==="
echo "TIME: $TS"
echo "LISTENING SERVICES: $LISTEN_N"
echo "ESTABLISHED CONNECTIONS: $ESTAB_N"
echo "UNEXPECTED EXPOSED PORTS: $EXPOSED_N"
echo "SUSPICIOUS REMOTE CONNECTIONS: $SUSPICIOUS_N"
echo "TOP PROCESS BY ESTABLISHED CONNECTIONS: $TOP_PROC"
echo "CLASSIFICATION: $CLASS"
