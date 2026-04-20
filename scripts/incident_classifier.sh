#!/bin/bash

# 1. Validar parámetros
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <CPU_THRESHOLD> <ERROR_THRESHOLD>"
    exit 1
fi

CPU_THRESHOLD=$1
LOG_THRESHOLD=$2

# Definir la Whitelist (igual que en Task 4)
WHITELIST=("bash" "sleep" "sshd" "systemd" "ps" "grep" "incident_classifier.sh")

# Variables de estado (0 = no detectado, 1 = detectado)
CPU_ANOMALY=0
UNAUTH_ANOMALY=0
LOG_ANOMALY=0

# --- INDICADOR 1: Uso de CPU ---
# Comprobamos si algún proceso supera el umbral de CPU
if ps -eo %cpu --no-headers | awk -v t="$CPU_THRESHOLD" '{if($1>t) exit 1}' ; then
    CPU_ANOMALY=0
else
    CPU_ANOMALY=1
fi

# --- INDICADOR 2: Procesos no autorizados ---
while read -r pid comm; do
    [ -z "$comm" ] && continue
    AUTHORIZED=false
    for item in "${WHITELIST[@]}"; do
        if [[ "$comm" == "$item" ]]; then
            AUTHORIZED=true
            break
        fi
    done
    if [ "$AUTHORIZED" = false ]; then
        UNAUTH_ANOMALY=1
        break # Con encontrar uno es suficiente
    fi
done < <(ps -eo pid,comm --no-headers)

# --- INDICADOR 3: Logs (ERROR entries) ---
for log_file in ../logs/*.log; do
    [ -e "$log_file" ] || continue
    error_count=$(grep "ERROR" "$log_file" | wc -l)
    if [ "$error_count" -gt "$LOG_THRESHOLD" ]; then
        LOG_ANOMALY=1
        break
    fi
done

# --- CLASIFICACIÓN FINAL ---
TOTAL_INDICATORS=$((CPU_ANOMALY + UNAUTH_ANOMALY + LOG_ANOMALY))

if [ "$TOTAL_INDICATORS" -eq 0 ]; then
    echo "NORMAL"
elif [ "$TOTAL_INDICATORS" -eq 1 ]; then
    echo "WARNING"
else
    echo "CRITICAL"
fi
