#!/bin/bash

# --- CONFIGURACIÓN ---
# Script para auditar conexiones TCP establecidas (ESTAB)
# Objetivo: Identificar flujos de datos activos y procesos responsables.

echo "--------------------------------------------------"
echo "INICIANDO AUDITORÍA DE CONEXIONES ESTABLECIDAS"
echo "--------------------------------------------------"

# Contador de conexiones
ESTAB_COUNT=0

# 1. Obtención de datos usando 'ss':
# -t: solo TCP
# -n: formato numérico
# -p: mostrar proceso y PID
# state established: filtro directo para conexiones activas
RAW_DATA=$(ss -tnp state established | tail -n +2)

# 2. Procesar cada línea
while read -r line; do
    if [ -n "$line" ]; then
        # Extraer puntos finales (Local y Remoto)
        LOCAL=$(echo $line | awk '{print $4}')
        REMOTE=$(echo $line | awk '{print $5}')
        
        # Extraer proceso y PID de la columna "users"
        PROC_INFO=$(echo $line | grep -o 'users:((.*))')
        PROCESS=$(echo $PROC_INFO | cut -d'"' -f2)
        PID=$(echo $PROC_INFO | grep -o 'pid=[0-9]*' | cut -d'=' -f2)

        # Normalizar si no hay info de proceso
        if [ -z "$PROCESS" ]; then PROCESS="unknown"; fi
        if [ -z "$PID" ]; then PID="N/A"; fi

        # 3. Mostrar salida en el formato requerido por el Task
        echo "ESTABLISHED CONNECTION: $LOCAL -> $REMOTE $PROCESS $PID"
        
        ((ESTAB_COUNT++))
    fi
done <<< "$RAW_DATA"

# 4. Resumen final
echo "--------------------------------------------------"
if [ $ESTAB_COUNT -eq 0 ]; then
    echo "NO ESTABLISHED CONNECTIONS DETECTED"
else
    echo "RESUMEN: Se detectaron $ESTAB_COUNT conexiones activas."
fi
echo "--------------------------------------------------"
