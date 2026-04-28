#!/bin/bash

# --- CONFIGURACIÓN ---
# Whitelist: Puertos esperados según el manual (5000 y 6000)
WHITELIST=(5000 6000)
TARGET="127.0.0.1"
UNEXPECTED_COUNT=0

echo "--------------------------------------------------"
echo "INICIANDO AUDITORÍA DE EXPOSICIÓN DE PUERTOS"
echo "Objetivo: $TARGET"
echo "--------------------------------------------------"

# 1. Escaneo con nmap:
# -p- : todos los puertos
# -Pn : sin ping
# -n  : sin DNS
# grep "open" : solo líneas de puertos abiertos
# awk -F'/' '{print $1}' : extrae solo el número del puerto
OPEN_PORTS=$(nmap -p- -Pn -n $TARGET | grep "open" | awk -F'/' '{print $1}')

# 2. Lógica de comparación con Whitelist
for PORT in $OPEN_PORTS; do
    IS_EXPECTED=false
    
    # Comprobar si el puerto detectado está en la lista blanca
    for EXPECTED in "${WHITELIST[@]}"; do
        if [ "$PORT" == "$EXPECTED" ]; then
            IS_EXPECTED=true
            break
        fi
    done

    # 3. Si el puerto no es esperado, reportarlo
    if [ "$IS_EXPECTED" = false ]; then
        echo "EXPOSED PORT: $PORT"
        ((UNEXPECTED_COUNT++))
    fi
done

# 4. Resumen final
echo "--------------------------------------------------"
if [ $UNEXPECTED_COUNT -eq 0 ]; then
    echo "NO UNEXPECTED EXPOSED PORTS"
else
    echo "RESUMEN: Se detectaron $UNEXPECTED_COUNT puertos inesperados."
fi
echo "--------------------------------------------------"

