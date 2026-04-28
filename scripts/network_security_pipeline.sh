#!/bin/bash
# BONUS TASK: Integrated Network Security Pipeline
# Este script coordina la ejecución de toda la auditoría.

MODE=$1
INTERVAL=${2:-10}

run_pipeline() {
    echo ">>> EJECUTANDO PIPELINE DE SEGURIDAD - $(date) <<<"
    echo "1. Ejecutando auditoría de puertos..."
    ./external_port_exposure_audit.sh
    echo "2. Ejecutando auditoría de servicios..."
    ./listening_service_audit.sh
    echo "3. Detectando conexiones sospechosas..."
    ./suspicious_remote_connection_audit.sh
    echo "4. Generando clasificación de incidente..."
    ./network_incident_classifier.sh
    echo "5. Creando Snapshot y Reporte oficial..."
    ./network_snapshot.sh
    ./mission_network_security_report.sh
    echo ">>> PIPELINE COMPLETADA <<<"
    echo "--------------------------------------------------"
}

if [ "$MODE" == "monitor" ]; then
    echo "Iniciando modo MONITOREO cada $INTERVAL segundos. (Ctrl+C para parar)"
    while true; do
        run_pipeline
        sleep $INTERVAL
    done
else
    echo "Iniciando modo SINGLE RUN..."
    run_pipeline
fi
