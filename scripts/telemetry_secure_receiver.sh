#!/bin/bash
PORT=5001
LOG_FILE="../reports/telemetry_secure.log"
SECRET_KEY="orion-shared-secret"
STATE_FILE="../reports/last_timestamp.db"

touch "$STATE_FILE"

echo "=== RECEPTOR CON PROTECCIÓN REPLAY (PORT $PORT) ==="

socat -u TCP4-LISTEN:$PORT,reuseaddr,fork STDOUT | while read -r line; do
    [ -z "$line" ] && continue

    DATA=$(echo "$line" | sed 's/; SIGNATURE=.*//')
    RECEIVED_SIGNATURE=$(echo "$line" | sed 's/.*; SIGNATURE=//')
    EXPECTED_SIGNATURE=$(printf "%s" "$DATA" | openssl dgst -sha256 -hmac "$SECRET_KEY" | cut -d ' ' -f2)

    # 1. Validar Firma HMAC
    if [ "$RECEIVED_SIGNATURE" != "$EXPECTED_SIGNATURE" ]; then
        echo "[REJECTED] INVALID SIGNATURE: $line" | tee -a "$LOG_FILE"
        continue
    fi

    # 2. Extraer Datos para Replay
    TIMESTAMP=$(echo "$DATA" | grep -o 'TIMESTAMP=[^;]*' | cut -d= -f2)
    SAT_ID=$(echo "$DATA" | grep -o 'SAT_ID=[^;]*' | cut -d= -f2)
    LAST_TS=$(grep "^$SAT_ID=" "$STATE_FILE" | cut -d= -f2)

    # 3. Comparación de Replay (Corregida para Bash)
    if [ -n "$LAST_TS" ]; then
        if [[ "$TIMESTAMP" < "$LAST_TS" || "$TIMESTAMP" == "$LAST_TS" ]]; then
            echo "[REJECTED] REPLAY DETECTED: $DATA" | tee -a "$LOG_FILE"
            continue
        fi
    fi

    # 4. Actualizar Estado y Aceptar
    TMP_FILE=$(mktemp)
    grep -v "^$SAT_ID=" "$STATE_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$STATE_FILE"
    echo "$SAT_ID=$TIMESTAMP" >> "$STATE_FILE"

    echo "[ACCEPTED] $DATA" | tee -a "$LOG_FILE"
done
