#!/bin/bash

HOST="127.0.0.1"
PORT="${PORT:-6004}"

USER_NAME="$1"
ROLE="$2"
CMD="$3"

if [ -z "$USER_NAME" ] || [ -z "$ROLE" ] || [ -z "$CMD" ]; then
    echo "Usage: $0 <user> <role> <command>"
    echo "Example: $0 alice operator SET_MODE_SAFE"
    echo ""
    echo "Optional: PORT=6004 $0 alice operator SET_MODE_SAFE"
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

TS=$(date -Iseconds)

# Generación de COMMAND_ID único usando fecha, hora y un número aleatorio
COMMAND_ID="CMD-$(date +%Y%m%d%H%M%S)-$RANDOM"

# 1. Crear los datos a autenticar (incluyendo COMMAND_ID)
DATA="USER=$USER_NAME;ROLE=$ROLE;CMD=$CMD;COMMAND_ID=$COMMAND_ID;TIMESTAMP=$TS"

# 2. Calcular el HMAC-SHA256 sobre toda la cadena DATA
AUTH=$(printf "%s" "$DATA" | openssl dgst -sha256 -hmac "$TOKEN" | cut -d' ' -f2)

# 3. Construir el mensaje final
MESSAGE="$DATA;AUTH=$AUTH"

echo "[SENDING] $MESSAGE"

if nc -h 2>&1 | grep -q -- "-q"; then
    echo "$MESSAGE" | nc -q 0 "$HOST" "$PORT"
else
    echo "$MESSAGE" | nc -N "$HOST" "$PORT"
fi
