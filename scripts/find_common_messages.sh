TEMP_FILE="all_messages.tmp"
> "$TEMP_FILE"

for file in ../logs/*.log
do
    if [ -f "$file" ]; then
        awk '{for(i=4;i<=NF;i++) printf "%s ", $i; print ""}' "$file" | sort -u >> "$TEMP_FILE"
    fi
done

echo "Mensajes que aparecen en más de un archivo log:"
echo "--------------------------------------------"


sort "$TEMP_FILE" | uniq -c | awk '$1 > 1 { $1=""; print $0 }'

rm "$TEMP_FILE"
