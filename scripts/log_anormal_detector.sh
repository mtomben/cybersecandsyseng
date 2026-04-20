#!/bin/bash

# 1. Verificar si se proporcionó el umbral
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <ERROR_THRESHOLD>"
    exit 1
fi

THRESHOLD=$1
MAX_ERRORS=-1
MOST_UNSTABLE_FILE=""

echo "Processing log files..."

# 2. Procesar todos los archivos .log en la carpeta ../logs/
for log_file in ../logs/*.log; do
    
    # Verificar si el archivo existe para evitar errores si la carpeta está vacía
    [ -e "$log_file" ] || continue

    # Extraer solo el nombre del archivo para el reporte
    base_name=$(basename "$log_file")

    # 3. Contar el número de entradas ERROR
    error_count=$(grep "ERROR" "$log_file" | wc -l)

    echo "$base_name: $error_count ERROR entries"

    # 4. Comparar con el umbral (Threshold)
    if [ "$error_count" -gt "$THRESHOLD" ]; then
        echo "ALERT: log anomaly detected in $base_name"
    fi

    # 5. Identificar el archivo con más errores
    if [ "$error_count" -gt "$MAX_ERRORS" ]; then
        MAX_ERRORS=$error_count
        MOST_UNSTABLE_FILE=$base_name
    fi
done

# 6. Reportar el archivo más inestable
if [ "$MAX_ERRORS" -ge 0 ]; then
    echo ""
    echo "Most unstable log file: $MOST_UNSTABLE_FILE ($MAX_ERRORS ERROR entries)"
fi
