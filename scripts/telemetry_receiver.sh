#!/bin/bash
echo "=== RECEPTOR SIMPLE ==="
# Usamos el puerto 8888 y guardamos directamente
socat -u TCP4-LISTEN:8888,reuseaddr,fork STDOUT | tee -a /home/maria/orion-system/reports/telemetry_insecure.log
