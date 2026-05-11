#!/bin/bash

PORT=6004
REPORT_DIR="../reports"
LOG_FILE="$REPORT_DIR/command_replay_protection.log"
STATE_FILE="$REPORT_DIR/processed_commands.db"
USER_DB="../credentials/user_db.txt"

mkdir -p "$REPORT_DIR"
touch "$LOG_FILE"
touch "$STATE_FILE"

echo "=== REPLAY-PROTECTED RECEIVER STARTED ==="
echo "Listening on 127.0.0.1:$PORT"
echo "Logging to $LOG_FILE"
echo "State Database: $STATE_FILE"
echo ""

while true; do
    nc -l 127.0.0.1 "$PORT" | while IFS= read -r line; do
        TS=$(date -Iseconds)

        # Extraer parámetros
        USER_NAME=$(echo "$line" | grep -o 'USER=[^;]*' | cut -d= -f2)
        ROLE=$(echo "$line" | grep -o 'ROLE=[^;]*' | cut -d= -f2)
        CMD=$(echo "$line" | grep -o 'CMD=[^;]*' | cut -d= -f2)
        COMMAND_ID=$(echo "$line" | grep -o 'COMMAND_ID=[^;]*' | cut -d= -f2)
        TIMESTAMP=$(echo "$line" | grep -o 'TIMESTAMP=[^;]*' | cut -d= -f2)
        RECEIVED_AUTH=$(echo "$line" | grep -o 'AUTH=[^;]*' | cut -d= -f2)

        echo "[RECEIVED $TS] USER=$USER_NAME ROLE=$ROLE CMD=$CMD COMMAND_ID=$COMMAND_ID"
        echo "[RECEIVED $TS] USER=$USER_NAME ROLE=$ROLE CMD=$CMD COMMAND_ID=$COMMAND_ID MSG_TS=$TIMESTAMP RAW=$line" >> "$LOG_FILE"

        # 1. VERIFICAR USUARIO
        ENTRY=$(grep "^$USER_NAME:" "$USER_DB")
        if [ -z "$ENTRY" ]; then
            echo "[REJECTED $TS] UNKNOWN USER: $USER_NAME"
            echo "[REJECTED $TS] UNKNOWN USER: $USER_NAME RAW=$line" >> "$LOG_FILE"
            echo ""
            continue
        fi

        DB_ROLE=$(echo "$ENTRY" | cut -d: -f2)
        DB_TOKEN=$(echo "$ENTRY" | cut -d: -f3)

        # 2. VALIDAR ROL
        if [ "$ROLE" != "$DB_ROLE" ]; then
            echo "[REJECTED $TS] ROLE MISMATCH: USER=$USER_NAME DECLARED=$ROLE EXPECTED=$DB_ROLE"
            echo "[REJECTED $TS] ROLE MISMATCH: USER=$USER_NAME RAW=$line" >> "$LOG_FILE"
            echo ""
            continue
        fi

        # 3. VERIFICACIÓN CRIPTOGRÁFICA (HMAC-SHA256)
        DATA="USER=$USER_NAME;ROLE=$ROLE;CMD=$CMD;COMMAND_ID=$COMMAND_ID;TIMESTAMP=$TIMESTAMP"
        EXPECTED_AUTH=$(printf "%s" "$DATA" | openssl dgst -sha256 -hmac "$DB_TOKEN" | cut -d' ' -f2)

        if [ "$RECEIVED_AUTH" != "$EXPECTED_AUTH" ]; then
            echo "[REJECTED $TS] INVALID AUTH: HMAC verification failed for user $USER_NAME"
            echo "[REJECTED $TS] INVALID AUTH: $USER_NAME RAW=$line" >> "$LOG_FILE"
            echo ""
            continue
        fi

        # 4. DETECCIÓN DE REPLAY (Solo tras verificar la autenticidad del mensaje)
        if grep -q "^$COMMAND_ID$" "$STATE_FILE"; then
            echo "[REJECTED $TS] REPLAY DETECTED: COMMAND_ID=$COMMAND_ID has already been processed!"
            echo "[REJECTED $TS] REPLAY DETECTED: COMMAND_ID=$COMMAND_ID RAW=$line" >> "$LOG_FILE"
            echo ""
            continue
        fi

        # Guardar COMMAND_ID en el archivo de estado
        echo "$COMMAND_ID" >> "$STATE_FILE"

        # 5. AUTORIZACIÓN (RBAC)
        AUTHORIZED="no"
        if [ "$ROLE" = "admin" ]; then
            case "$CMD" in
                SET_MODE_NOMINAL|SET_MODE_SAFE|RESET|SHUTDOWN)
                    AUTHORIZED="yes"
                    ;;
            esac
        elif [ "$ROLE" = "operator" ]; then
            case "$CMD" in
                SET_MODE_NOMINAL|SET_MODE_SAFE)
                    AUTHORIZED="yes"
                    ;;
            esac
        fi

        if [ "$AUTHORIZED" != "yes" ]; then
            echo "[REJECTED $TS] UNAUTHORIZED USER=$USER_NAME ROLE=$ROLE CMD=$CMD"
            echo "[REJECTED $TS] UNAUTHORIZED USER=$USER_NAME ROLE=$ROLE CMD=$CMD RAW=$line" >> "$LOG_FILE"
            echo ""
            continue
        fi

        echo "[AUTHORIZED $TS] USER=$USER_NAME ROLE=$ROLE CMD=$CMD COMMAND_ID=$COMMAND_ID"
        echo "[AUTHORIZED $TS] USER=$USER_NAME ROLE=$ROLE CMD=$CMD RAW=$line" >> "$LOG_FILE"

        case "$CMD" in
            SET_MODE_NOMINAL)
                echo "[ACTION] Switching satellite mode to NOMINAL"
                echo "[ACTION $TS] SET_MODE_NOMINAL" >> "$LOG_FILE"
                ;;
            SET_MODE_SAFE)
                echo "[ACTION] Switching satellite mode to SAFE"
                echo "[ACTION $TS] SET_MODE_SAFE" >> "$LOG_FILE"
                ;;
            RESET)
                echo "[ACTION] Simulated satellite reset"
                echo "[ACTION $TS] RESET" >> "$LOG_FILE"
                ;;
            SHUTDOWN)
                echo "[ACTION] Simulated satellite shutdown"
                echo "[ACTION $TS] SHUTDOWN" >> "$LOG_FILE"
                ;;
        esac

        echo ""
    done
done
