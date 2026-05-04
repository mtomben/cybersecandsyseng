#!/bin/bash
# Lab 6 - Emisor de Telemetría (Satélite)
SAT_ID="ORION-SAT-01"

echo "=== SATÉLITE ENVIANDO DATOS AL PUERTO 8888 ==="
echo "Presiona Ctrl+C para detener"
echo "----------------------------------------------"

while true; do
    TS=$(date -u +"%Y-%m-%dT%H:%M:%S+00:00")
    VALUE=$((RANDOM % 100))
    MESSAGE="SAT_ID=$SAT_ID;TIMESTAMP=$TS;VALUE=$VALUE"
    
    # Envía el mensaje al receptor
    echo "$MESSAGE" | nc -w 1 127.0.0.1 8888
    
    echo "ENVIADO: $MESSAGE"
    sleep 2
done
