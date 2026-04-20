#!/bin/bash

# 1. Definir rutas y nombres de archivos temporales para los datos
TMP_DIR="/tmp/orion_delta"
mkdir -p $TMP_DIR

echo "Generando el primer snapshot..."
./runtime_snapshot.sh > /dev/null
# Buscamos el reporte más reciente generado
SNAP1=$(ls -t ../reports/runtime_snapshot_*.txt | head -n 1)
cp "$SNAP1" "$TMP_DIR/snap1.txt"

echo "Esperando 5 segundos para detectar cambios..."
sleep 5

echo "Generando el segundo snapshot..."
./runtime_snapshot.sh > /dev/null
SNAP2=$(ls -t ../reports/runtime_snapshot_*.txt | head -n 1)
cp "$SNAP2" "$TMP_DIR/snap2.txt"

# --- EXTRACCIÓN DE DATOS (Parsing) ---

# Extraer Top CPU (solo el nombre del proceso)
CPU1=$(grep "Top CPU process:" "$TMP_DIR/snap1.txt" | awk -F'PROC=' '{print $2}' | awk '{print $1}')
CPU2=$(grep "Top CPU process:" "$TMP_DIR/snap2.txt" | awk -F'PROC=' '{print $2}' | awk '{print $1}')

# Extraer conteo de procesos no autorizados
UNAUTH1=$(grep "Unauthorized processes:" "$TMP_DIR/snap1.txt" | awk '{print $3}')
UNAUTH2=$(grep "Unauthorized processes:" "$TMP_DIR/snap2.txt" | awk '{print $3}')

# Extraer clasificación de incidente
CLASS1=$(grep "Incident classification:" "$TMP_DIR/snap1.txt" | awk '{print $3}')
CLASS2=$(grep "Incident classification:" "$TMP_DIR/snap2.txt" | awk '{print $3}')

# --- COMPARACIÓN Y SALIDA ---

echo -e "\n----------------------------------------"
echo "STATE CHANGE DETECTED:"
echo "----------------------------------------"

# Comparar Top CPU
if [ "$CPU1" == "$CPU2" ]; then
    echo "Top CPU process changed: NO"
else
    echo "Top CPU process changed: YES ($CPU1 -> $CPU2)"
fi

# Comparar Procesos No Autorizados
if [ "$UNAUTH1" == "$UNAUTH2" ]; then
    echo "Unauthorized process count changed: NO"
else
    echo "Unauthorized process count changed: YES ($UNAUTH1 -> $UNAUTH2)"
fi

# Comparar Clasificación
if [ "$CLASS1" == "$CLASS2" ]; then
    echo "Incident classification changed: NO"
else
    echo "Incident classification changed: YES ($CLASS1 -> $CLASS2)"
fi
echo "----------------------------------------"

# Limpieza
rm -rf $TMP_DIR
