#!/bin/bash

# --- CONFIGURACIÓN ---
INTERVAL=5          # Intervalo en segundos
REPORT_DIR="../reports"
REPORT_FILE="$REPORT_DIR/network_monitoring_$(date +%Y%m%d_%H%M%S).log"

# Asegurar que el directorio de reportes existe
mkdir -p "$REPORT_DIR"

echo "--------------------------------------------------"
echo "SISTEMA DE MONITOREO ORION: ACTIVO"
echo "Intervalo: ${INTERVAL}s | Reporte: $REPORT_FILE"
echo "Presiona Ctrl+C para detener el monitoreo de forma segura."
echo "--------------------------------------------------"

# Encabezado del archivo de log
echo "# Timestamp LISTEN ESTAB EXPOSED SUSPICIOUS CLASS" > "$REPORT_FILE"

# Bucle de monitoreo infinito
trap "echo -e '\nMonitoreo detenido por el usuario.'; exit" SIGINT

while true; do
    # 1. Obtener Timestamp
    TS=$(date "+%Y-%m-%d_%H:%M:%S")

    # 2. Recolectar datos reutilizando tus scripts previos
    # Usamos 'wc -l' para contar líneas de salida de cada auditoría
    # Nota: Restamos las líneas de encabezado si el script las imprime
    LISTEN_N=$(./listening_service_audit.sh | grep "LISTENING SERVICE" | wc -l)
    ESTAB_N=$(./established_connection_audit.sh | grep "ESTABLISHED CONNECTION" | wc -l)
    EXPOSED_N=$(./external_port_exposure_audit.sh | grep "EXPOSED PORT" | wc -l)
    SUSPICIOUS_N=$(./suspicious_remote_connection_audit.sh | grep "SUSPICIOUS CONNECTION" | wc -l)
    
    # 3. Obtener clasificación del Task 7
    CLASS=$(./network_incident_classifier.sh | grep "CLASIFICACIÓN:" | awk '{print $2}')

    # 4. Formatear entrada en una sola línea
    ENTRY="$TS LISTEN=$LISTEN_N ESTAB=$ESTAB_N EXPOSED=$EXPOSED_N SUSPICIOUS=$SUSPICIOUS_N CLASS=$CLASS"

    # 5. Guardar en archivo y mostrar en pantalla
    echo "$ENTRY" >> "$REPORT_FILE"
    echo "$ENTRY"

    # Esperar el intervalo configurado
    sleep $INTERVAL
done
