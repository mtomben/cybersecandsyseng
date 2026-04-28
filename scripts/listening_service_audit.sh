#!/bin/bash

# --- CONFIGURACIÓN ---
# Script para auditar servicios en escucha (TCP y UDP)
# Requisito: Debe mostrar protocolo, dirección:puerto, proceso y PID.

echo "--------------------------------------------------"
echo "INICIANDO AUDITORÍA INTERNA DE SERVICIOS (LISTEN)"
echo "--------------------------------------------------"

# Contador de servicios
SERVICE_COUNT=0

# 1. Obtención de datos usando 'ss':
# -l: solo sockets en escucha
# -n: formato numérico
# -t: TCP
# -u: UDP
# -p: mostrar proceso y PID
# El sed y awk limpian la salida para procesarla línea a línea
# Saltamos la primera línea (cabecera) con tail -n +2
RAW_DATA=$(ss -lnptua | tail -n +2)

# 2. Procesar cada línea de la salida
while read -r line; do
    if [ -n "$line" ]; then
        # Extraer campos
        PROTO=$(echo $line | awk '{print $1}')
        ADDR_PORT=$(echo $line | awk '{print $5}')
        
        # Extraer proceso y PID de la columna "users"
        # Formato esperado de ss: users:(("nc",pid=8754,fd=3))
        PROC_INFO=$(echo $line | grep -o 'users:((.*))')
        PROCESS=$(echo $PROC_INFO | cut -d'"' -f2)
        PID=$(echo $PROC_INFO | grep -o 'pid=[0-9]*' | cut -d'=' -f2)

        # Si no hay PID/Proceso (ej. sockets del kernel), poner "N/A"
        if [ -z "$PROCESS" ]; then PROCESS="unknown"; fi
        if [ -z "$PID" ]; then PID="N/A"; fi

        # 3. Mostrar salida en el formato requerido
        echo "LISTENING SERVICE: $PROTO $ADDR_PORT $PROCESS $PID"
        
        ((SERVICE_COUNT++))
    fi
done <<< "$RAW_DATA"

# 4. Resumen final
echo "--------------------------------------------------"
if [ $SERVICE_COUNT -eq 0 ]; then
    echo "NO LISTENING SERVICES DETECTED"
else
    echo "RESUMEN: Se detectaron $SERVICE_COUNT servicios escuchando localmente."
fi
echo "--------------------------------------------------"
