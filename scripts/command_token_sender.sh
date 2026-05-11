#!/bin/bash

HOST="127.0.0.1"
PORT="${PORT:-6002}"

USER_NAME="$1"
ROLE="$2"
CMD="$3"

if [ -z "$USER_NAME" ] || [ -z "$ROLE" ] || [ -z "$CMD" ]; then
    echo "Usage: $0 <user> <role> <command>"
    echo "Example: $0 alice operator SET_MODE_SAFE"
    echo ""
    echo "Optional: PORT=6002 $0 alice operator SET_MODE_SAFE"
    exit 1
fi

# Asignación de Token basada en el usuario
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
# Formato extendido con TOKEN
MESSAGE="USER=$USER_NAME;ROLE=$ROLE;CMD=$CMD;TOKEN=$TOKEN;TIMESTAMP=$TS"

echo "[SENDING] $MESSAGE"

if nc -h 2>&1 | grep -q -- "-q"; then
    echo "$MESSAGE" | nc -q 0 "$HOST" "$PORT"
else
    echo "$MESSAGE" | nc -N "$HOST" "$PORT"
fi
