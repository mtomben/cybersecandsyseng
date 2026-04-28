#!/bin/bash

# --- CONFIGURACIÓN ---
# Este script consolida indicadores de red y de sistema para clasificar el estado de seguridad.
# Reutiliza la lógica de auditorías previas.

echo "=================================================="
echo "   SISTEMA ORION: CLASIFICADOR DE INCIDENTES"
echo "=================================================="

# Inicialización de estados
PORT_EXPOSURE="INACTIVE"
REMOTE_CONN="INACTIVE"
CPU_LOAD="INACTIVE"
LOG_ANOMALY="INACTIVE"
ACTIVE_COUNT=0

# 1. CATEGORÍA: Puertos Externos Inesperados (Reutiliza Task 3)
# Si el script de la Task 3 detecta algún puerto que no sea 5000/6000
if ./external_port_exposure_audit.sh | grep -q "EXPOSED PORT"; then
    PORT_EXPOSURE="ACTIVE"
    ((ACTIVE_COUNT++))
fi

# 2. CATEGORÍA: Conexiones Remotas Sospechosas (Reutiliza Task 6)
# Si hay conexiones que no sean a 127.0.0.1 o ::1
if ./suspicious_remote_connection_audit.sh | grep -q "SUSPICIOUS CONNECTION"; then
    REMOTE_CONN="ACTIVE"
    ((ACTIVE_COUNT++))
fi

# 3. CATEGORÍA: Proceso de CPU Alto (Lógica Lab 4)
# Simulamos/detectamos si hay un proceso consumiendo > 80% (ajustar según tu script de Lab 4)
# Aquí usamos una detección rápida de top
if top -bn1 | awk 'NR>7 {if($9>80) print $0}' | grep -q "."; then
    CPU_LOAD="ACTIVE"
    ((ACTIVE_COUNT++))
fi

# 4. CATEGORÍA: Anomalías en Logs (Lógica Lab 4)
# Buscamos patrones de error críticos o "failed" en /var/log/syslog o archivos de orion
if grep -qiE "failed|error|critical|unauthorized" /var/log/syslog 2>/dev/null | tail -n 5 | grep -q "."; then
    LOG_ANOMALY="ACTIVE"
    ((ACTIVE_COUNT++))
fi

# --- RESUMEN DE INDICADORES ---
echo "ESTADO DE CATEGORÍAS:"
echo "[-] Exposición de Puertos:  $PORT_EXPOSURE"
echo "[-] Conexión Remota:        $REMOTE_CONN"
echo "[-] Carga Crítica de CPU:   $CPU_LOAD"
echo "[-] Anomalías de Logs:      $LOG_ANOMALY"
echo "--------------------------------------------------"
echo "Total de categorías activas: $ACTIVE_COUNT"

# --- LÓGICA DE CLASIFICACIÓN ---
echo -n "CLASIFICACIÓN FINAL: "
if [ $ACTIVE_COUNT -eq 0 ]; then
    echo "NORMAL"
elif [ $ACTIVE_COUNT -eq 1 ]; then
    echo "WARNING"
else
    echo "CRITICAL"
fi
echo "=================================================="
