#!/bin/bash

# --- CONFIGURACIÓN ---
# Script para auditar comunicaciones remotas sospechosas.
# REGLA DE DETECCIÓN: 
# Una conexión es SOSPECHOSA si la IP remota NO ES 127.0.0.1 ni ::1.

echo "--------------------------------------------------"
echo "INICIANDO AUDITORÍA DE COMUNICACIONES SOSPECHOSAS"
echo "--------------------------------------------------"

SUSPICIOUS_COUNT=0

# 1. Obtener conexiones TCP establecidas
# Usamos -t (TCP), -n (numérico), -p (procesos) y filtro de estado 'established'
RAW_DATA=$(ss -tnp state established | tail -n +2)

# 2. Procesar línea a línea
while read -r line; do
    if [ -n "$line" ]; then
        # Extraer la IP remota y el puerto (columna 5)
        # Formato habitual de ss: 192.168.1.15:443 o [::1]:631
        REMOTE_ADDR_PORT=$(echo $line | awk '{print $5}')
        
        # Extraer solo la IP para la comparación (quitando el puerto)
        # Manejamos IPv4 e IPv6
        REMOTE_IP=$(echo $REMOTE_ADDR_PORT | rev | cut -d':' -f2- | rev | sed 's/\[//g; s/\]//g')

        # 3. Implementación de la Regla de Detección
        if [[ "$REMOTE_IP" != "127.0.0.1" && "$REMOTE_IP" != "::1" ]]; then
            
            # Extraer proceso y PID
            PROC_INFO=$(echo $line | grep -o 'users:((.*))')
            PROCESS=$(echo $PROC_INFO | cut -d'"' -f2)
            PID=$(echo $PROC_INFO | grep -o 'pid=[0-9]*' | cut -d'=' -f2)

            # Normalizar si no hay info
            if [ -z "$PROCESS" ]; then PROCESS="unknown"; fi
            if [ -z "$PID" ]; then PID="N/A"; fi

            # 4. Mostrar salida en el formato requerido
            echo "SUSPICIOUS CONNECTION: $PROCESS $PID -> $REMOTE_ADDR_PORT"
            
            ((SUSPICIOUS_COUNT++))
        fi
    fi
done <<< "$RAW_DATA"

# 5. Resumen final
echo "--------------------------------------------------"
if [ $SUSPICIOUS_COUNT -eq 0 ]; then
    echo "NO SUSPICIOUS REMOTE CONNECTIONS DETECTED"
else
    echo "RESUMEN: Se detectaron $SUSPICIOUS_COUNT comunicaciones sospechosas."
fi
echo "--------------------------------------------------"
