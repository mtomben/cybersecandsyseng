#!/bin/bash
PORT=5001
SECRET_KEY="orion-shared-secret"
SAT_ID="ORION-SAT-01"

while true; do
    TS=$(date -u +"%Y-%m-%dT%H:%M:%S+00:00")
    VALUE=$((RANDOM % 100))
    MESSAGE="SAT_ID=$SAT_ID; TIMESTAMP=$TS; VALUE=$VALUE"
    
    SIGNATURE=$(printf "%s" "$MESSAGE" | openssl dgst -sha256 -hmac "$SECRET_KEY" | cut -d ' ' -f2)
    SIGNED_MESSAGE="$MESSAGE; SIGNATURE=$SIGNATURE"
    
    # Usamos -q 0 para evitar que netcat se quede colgado
    echo "$SIGNED_MESSAGE" | nc -q 0 127.0.0.1 $PORT
    
    echo "SENT: $SIGNED_MESSAGE"
    sleep 2
done
