#!/bin/bash

HOST="127.0.0.1"
PORT="${PORT:-7005}"

USER_NAME="$1"
ROLE="$2"
CMD="$3"
REQUEST_ID=$4

if [ -z "$USER_NAME" ] || [ -z "$ROLE" ] || [ -z "$CMD" ]; then
    echo "Usage: $0 <user> <role> <command> [request_id]"
    echo "Example: $0 alice operator SET_MODE_SAFE"
    echo "Example confirm: $0 bob admin CONFIRM REQ-12345"
    echo ""
    echo "Optional: PORT=6005 $0 alice operator SET_MODE_SAFE"
    exit 1
fi

# Asignación de Token local
case "$USER_NAME" in
    alice)
        TOKEN="token-alice-123"
        ;;
    bob)
        TOKEN="token-bob-999"
        ;;
    *)
        TOKEN="unknown"
        ;;
esac

# Generamos el COMMAND_ID y TIMESTAMP
TS=$(date -Iseconds)
COMMAND_ID="CMD-$(date +%Y%m%d%H%M%S)-$RANDOM"

# 1. Crear los datos a autenticar
# Si nos pasan un REQUEST_ID (es decir, es una confirmación), lo incluimos
if [ -n "$REQUEST_ID" ]; then
    DATA="USER=$USER_NAME; ROLE=$ROLE; CMD=$CMD; REQUEST_ID=$REQUEST_ID; COMMAND_ID=$COMMAND_ID; TIMESTAMP=$TS"
else
    # Si es un comando normal, no lo incluimos
    DATA="USER=$USER_NAME; ROLE=$ROLE; CMD=$CMD; COMMAND_ID=$COMMAND_ID; TIMESTAMP=$TS"
fi

# 2. Calcular el HMAC-SHA256 sobre toda la cadena DATA
AUTH=$(printf "%s" "$DATA" | openssl dgst -sha256 -hmac "$TOKEN" | cut -d' ' -f2)

# 3. Construir el mensaje final
MESSAGE="$DATA; AUTH=$AUTH"

echo "[SENDING] $MESSAGE"

echo "$MESSAGE" | openssl s_client -quiet -connect "$HOST:$PORT"
