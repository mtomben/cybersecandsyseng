#!/bin/bash

# Configuración de umbrales
CPU_THRESHOLD=50
LOG_THRESHOLD=10
WHITELIST=("bash" "sleep" "sshd" "systemd" "ps" "grep" "runtime_snapshot.sh" "incident_classifier.sh")

# Preparar archivo de reporte
mkdir -p ../reports
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT_FILE="../reports/runtime_snapshot_$TIMESTAMP.txt"

# --- RECOLECCIÓN DE DATOS ---

# 1. Fecha y procesos totales
NOW=$(date +"%Y-%m-%d %H:%M:%S")
TOTAL_PROC=$(ps -e --no-headers | wc -l)

# 2. Top CPU
TOP_PROC_INFO=$(ps -eo pid,comm,%cpu --sort=-%cpu --no-headers | head -n 1)
read -r T_PID T_COMM T_CPU <<< "$TOP_PROC_INFO"

# 3. Procesos no autorizados
UNAUTH_LIST=()
while read -r p_pid p_comm; do
    [ -z "$p_comm" ] && continue
    AUTHORIZED=false
    for item in "${WHITELIST[@]}"; do
        if [[ "$p_comm" == "$item" ]]; then AUTHORIZED=true; break; fi
    done
    if [ "$AUTHORIZED" = false ]; then
        UNAUTH_LIST+=("PID=$p_pid PROC=$p_comm")
    fi
done < <(ps -eo pid,comm --no-headers)
UNAUTH_COUNT=${#UNAUTH_LIST[@]}

# 4. Logs
TOTAL_ERRORS=0
LOG_DETAILS=""
MAX_ERR=-1
UNSTABLE_LOG=""

for log_file in ../logs/*.log; do
    if [ -e "$log_file" ]; then
        bname=$(basename "$log_file")
        errors=$(grep "ERROR" "$log_file" | wc -l)
        TOTAL_ERRORS=$((TOTAL_ERRORS + errors))
        LOG_DETAILS+="- $bname: $errors ERROR entries\n"
        if [ "$errors" -gt "$MAX_ERR" ]; then
            MAX_ERR=$errors
            UNSTABLE_LOG=$bname
        fi
    fi
done

# 5. Clasificación (Indicadores gatillados)
INDICATORS_TEXT=""
NUM_INDICATORS=0

if (( $(echo "$T_CPU > $CPU_THRESHOLD" | bc -l) )); then
    INDICATORS_TEXT+="- high CPU: top process $T_COMM (PID=$T_PID) uses $T_CPU% > threshold $CPU_THRESHOLD%\n"
    ((NUM_INDICATORS++))
fi

if [ "$UNAUTH_COUNT" -gt 0 ]; then
    INDICATORS_TEXT+="- unauthorized processes detected: $UNAUTH_COUNT\n"
    ((NUM_INDICATORS++))
fi

LOG_ANOM_DETECTED="NO"
if [ "$MAX_ERR" -gt "$LOG_THRESHOLD" ]; then
    INDICATORS_TEXT+="- log anomaly: at least one mission log exceeds ERROR threshold $LOG_THRESHOLD\n"
    LOG_ANOM_DETECTED="YES"
    ((NUM_INDICATORS++))
fi

# Determinar Status
if [ "$NUM_INDICATORS" -eq 0 ]; then
    STATUS="NORMAL"
    SUMMARY="all indicators within safe limits"
elif [ "$NUM_INDICATORS" -eq 1 ]; then
    STATUS="WARNING"
    SUMMARY="exactly one suspicious indicator was observed"
else
    STATUS="CRITICAL"
    SUMMARY="at least two suspicious indicators were observed simultaneously"
fi

# --- GENERACIÓN DEL SNAPSHOT ---
{
echo "========================================"
echo "Runtime Security Snapshot"
echo "========================================"
echo "Date and time: $NOW"
echo "Total active processes: $TOTAL_PROC"
echo "Top CPU process: PID=$T_PID PROC=$T_COMM CPU=$T_CPU%"
echo "Unauthorized processes: $UNAUTH_COUNT"
echo "Total ERROR entries across all logs: $TOTAL_ERRORS"
echo "Incident classification: $STATUS"
echo "Classification summary: $SUMMARY"
echo "----------------------------------------"
echo "Thresholds:"
echo "- CPU threshold: $CPU_THRESHOLD%"
echo "- ERROR threshold per log: $LOG_THRESHOLD"
echo "----------------------------------------"
echo "Triggered indicators:"
[ -z "$INDICATORS_TEXT" ] && echo "None" || echo -e "$INDICATORS_TEXT" | sed '/^$/d'
echo "----------------------------------------"
echo "Log summary:"
echo -e "$LOG_DETAILS" | sed '/^$/d'
echo "Most unstable log: $UNSTABLE_LOG ($MAX_ERR ERROR entries)"
echo "----------------------------------------"
echo "Unauthorized process details:"
if [ "$UNAUTH_COUNT" -gt 0 ]; then
    for item in "${UNAUTH_LIST[@]}"; do echo "- $item"; done
else
    echo "None"
fi
} > "$REPORT_FILE"

# Mostrar por pantalla donde se guardó
echo "Snapshot generated: $REPORT_FILE"
cat "$REPORT_FILE"
