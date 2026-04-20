#!/bin/bash

# Configuración de umbrales para los scripts internos
CPU_THRESHOLD=20
LOG_THRESHOLD=5
INTERVAL=5

# Crear directorio de reportes si no existe
mkdir -p ../reports

# Definir nombre del archivo de reporte con timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%MSS")
REPORT_FILE="../reports/runtime_monitor_$TIMESTAMP.txt"

# Whitelist (debe coincidir con la de Task 4 y 6)
WHITELIST=("bash" "sleep" "sshd" "systemd" "ps" "grep" "runtime_monitor.sh" "incident_classifier.sh")

echo "Starting monitoring loop..."
echo "Interval: ${INTERVAL}s"
echo "Output: $REPORT_FILE"
echo "Press Ctrl+C to stop."
echo "----------------------------------------"

# Cabecera del archivo de reporte
echo "===== Monitoring started: $(date +"%Y-%m-%d %H:%M:%S") =====" > "$REPORT_FILE"

# Bucle de monitoreo
while true
do
    CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")

    # 1. Obtener el proceso con mayor CPU
    TOP_PROC_INFO=$(ps -eo comm,pid,%cpu --sort=-%cpu --no-headers | head -n 1)
    read -r TOP_COMM TOP_PID TOP_CPU <<< "$TOP_PROC_INFO"

    # 2. Contar procesos no autorizados
    UNAUTH_COUNT=0
    while read -r p_comm; do
        AUTHORIZED=false
        for item in "${WHITELIST[@]}"; do
            if [[ "$p_comm" == "$item" ]]; then AUTHORIZED=true; break; fi
        done
        if [ "$AUTHORIZED" = false ]; then ((UNAUTH_COUNT++)); fi
    done < <(ps -eo comm --no-headers)

    # 3. Detectar anomalía en logs (Task 5 logic)
    LOG_ANOMALY="NO"
    for log_file in ../logs/*.log; do
        if [ -e "$log_file" ]; then
            error_count=$(grep "ERROR" "$log_file" | wc -l)
            if [ "$error_count" -gt "$LOG_THRESHOLD" ]; then
                LOG_ANOMALY="YES"
                break
            fi
        fi
    done

    # 4. Obtener clasificación de incidente (Llamando al script de la Task 6)
    # Redirigimos stderr a /dev/null para una salida limpia
    STATUS=$(./incident_classifier.sh $CPU_THRESHOLD $LOG_THRESHOLD 2>/dev/null)

    # 5. Formatear línea de log
    LOG_LINE="[$CURRENT_TIME] TOP_CPU: $TOP_COMM (PID=$TOP_PID, CPU=$TOP_CPU%) | UNAUTHORIZED: $UNAUTH_COUNT | LOG_ANOMALY: $LOG_ANOMALY | STATUS: $STATUS"
    
    # Mostrar en pantalla y guardar en archivo
    echo "$LOG_LINE"
    echo "$LOG_LINE" >> "$REPORT_FILE"

    sleep $INTERVAL
done
