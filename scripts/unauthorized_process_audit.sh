#!/bin/bash

# 1. Definir la lista blanca (whitelist)
# Puedes añadir más nombres separados por espacios, ej: "bash sleep sshd"
WHITELIST=("bash" "sleep" "sshd" "systemd" "ps" "grep")

# Inicializar contadores
AUTH_COUNT=0
UNAUTH_COUNT=0

# 2. Inspeccionar procesos activos
# Usamos -e para todos y -o para extraer PID y COMM
ps -eo pid,comm --no-headers | while read -r pid comm; do
    
    # Ignorar la línea del propio script y procesos vacíos si los hay
    if [ -z "$comm" ]; then continue; fi

    AUTHORIZED=false

    # 3. Comparar el proceso con la whitelist
    for item in "${WHITELIST[@]}"; do
        if [[ "$comm" == "$item" ]]; then
            AUTHORIZED=true
            break
        fi
    done

    # 4. Clasificar y mostrar resultados
    if [ "$AUTHORIZED" = true ]; then
        echo "AUTHORIZED PROCESS: $comm (PID: $pid)"
        ((AUTH_COUNT++))
    else
        echo "UNAUTHORIZED PROCESS: $comm (PID: $pid)"
        ((UNAUTH_COUNT++))
    fi

    # Guardar los conteos en archivos temporales porque el pipe corre en un subshell
    echo $AUTH_COUNT > /tmp/auth_total
    echo $UNAUTH_COUNT > /tmp/unauth_total
done

# 5. Mostrar totales
TOTAL_AUTH=$(cat /tmp/auth_total)
TOTAL_UNAUTH=$(cat /tmp/unauth_total)

echo "---"
echo "TOTAL AUTHORIZED: $TOTAL_AUTH"
echo "TOTAL UNAUTHORIZED: $TOTAL_UNAUTH"

# Limpieza
rm /tmp/auth_total /tmp/unauth_total
