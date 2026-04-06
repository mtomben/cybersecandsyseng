
if [ -z "$1" ]; then
    echo "Error: Give a pattern (INFO, WARN o ERROR)" 
    exit 1
fi

PATTERN=$1
OUTPUT_FILE="../reports/pattern_timestamps.txt"

> "$OUTPUT_FILE"


for file in ../logs/*.log
do
   
    grep "$PATTERN" "$file" | awk '{print $1, $2}' >> "$OUTPUT_FILE"
done

echo "Timestamps $PATTERN exports to $OUTPUT_FILE"
