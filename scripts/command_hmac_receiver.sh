#!/bin/bash

PORT=6003
REPORT_DIR="../reports"
LOG_FILE="$REPORT_DIR/command_hmac_authentication.log"
USER_DB="../credentials/user_db.txt"

mkdir -p "$REPORT_DIR"
touch "$LOG_FILE"

echo "=== HMAC-BASED AUTHORIZED RECEIVER STARTED ==="
echo "Listening on 127.0.0.1:$PORT"
echo "Logging to $LOG_FILE"
echo "Database: $USER_DB"
echo ""

while true; do
    nc -l 127.0.0.1 "$PORT" | while IFS= read -r line; do
        TS=$(date -Iseconds)

        # Extraer parámetros del mensaje
        USER_NAME=$(echo "$line" | grep -o 'USER=[^;]*' | cut -d= -f2)
        ROLE=$(echo "$line" | grep -o 'ROLE=[^;]*' | cut -d= -f2)
        CMD=$(echo "$line" | grep -o 'CMD=[^;]*' | cut -d= -f2)
        TIMESTAMP=$(echo "$line" | grep -o 'TIMESTAMP=[^;]*' | cut -d= -f2)
        RECEIVED_AUTH=$(echo "$line" | grep -o 'AUTH=[^;]*' | cut -d= -f2)

        echo "[RECEIVED $TS] USER=$USER_NAME ROLE=$ROLE CMD=$CMD AUTH=$RECEIVED_AUTH"
        echo "[RECEIVED $TS] USER=$USER_NAME ROLE=$ROLE CMD=$CMD MSG_TS=$TIMESTAMP RAW=$line" >> "$LOG_FILE"

        # 1. VERIFICAR SI EL USUARIO EXISTE
        ENTRY=$(grep "^$USER_NAME:" "$USER_DB")
        if [ -z "$ENTRY" ]; then
            echo "[REJECTED $TS] UNKNOWN USER: $USER_NAME"
            echo "[REJECTED $TS] UNKNOWN USER: $USER_NAME RAW=$line" >> "$LOG_FILE"
            echo ""
            continue
        fi

        # Extraer datos esperados de la DB
        DB_ROLE=$(echo "$ENTRY" | cut -d: -f2)
        DB_TOKEN=$(echo "$ENTRY" | cut -d: -f3)

        # 2. VALIDAR COHERENCIA DE ROL (Evitar que cambien el rol en tránsito)
        if [ "$ROLE" != "$DB_ROLE" ]; then
            echo "[REJECTED $TS] ROLE MISMATCH: USER=$USER_NAME DECLARED_ROLE=$ROLE EXPECTED_ROLE=$DB_ROLE"
            echo "[REJECTED $TS] ROLE MISMATCH: USER=$USER_NAME RAW=$line" >> "$LOG_FILE"
            echo ""
            continue
        fi

        # 3. RECONSTRUIR EL PAYLOAD Y VERIFICAR HMAC
        DATA="USER=$USER_NAME;ROLE=$ROLE;CMD=$CMD;TIMESTAMP=$TIMESTAMP"
        EXPECTED_AUTH=$(printf "%s" "$DATA" | openssl dgst -sha256 -hmac "$DB_TOKEN" | cut -d' ' -f2)

        if [ "$RECEIVED_AUTH" != "$EXPECTED_AUTH" ]; then
            echo "[REJECTED $TS] INVALID AUTH: Cryptographic Verification Failed for user $USER_NAME"
            echo "[REJECTED $TS] INVALID AUTH: $USER_NAME RAW=$line" >> "$LOG_FILE"
            echo ""
            continue
        fi

        # 4. AUTORIZACIÓN (RBAC)
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

        echo "[AUTHORIZED $TS] USER=$USER_NAME ROLE=$ROLE CMD=$CMD"
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
