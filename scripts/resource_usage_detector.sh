#!/bin/bash

# Verificar argumentos
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <threshold_cpu> <threshold_mem>"
    exit 1
fi

CPU_THRESHOLD=$1
MEM_THRESHOLD=$2

# Usamos LC_NUMERIC=C para forzar que el sistema use puntos (.) y no comas (,)
# Además, filtramos la salida para que sea procesable
ps -eo pid,comm,%cpu,%mem --no-headers | while read -r pid comm cpu mem; do
    
    # Reemplazamos la coma por punto en caso de que exista
    cpu=$(echo $cpu | tr ',' '.')
    mem=$(echo $mem | tr ',' '.')

    # Verificamos que cpu y mem sean números válidos antes de pasarlos a bc
    if [[ $cpu =~ ^[0-9.]+$ ]] && [[ $mem =~ ^[0-9.]+$ ]]; then
        
        # Comprobación de CPU
        if (( $(echo "$cpu > $CPU_THRESHOLD" | bc -l) )); then
            echo "WARNING: suspicious CPU usage: $comm (PID: $pid)"
        fi

        # Comprobación de Memoria
        if (( $(echo "$mem > $MEM_THRESHOLD" | bc -l) )); then
            echo "WARNING: suspicious memory usage: $comm (PID: $pid)"
        fi
    fi
done
