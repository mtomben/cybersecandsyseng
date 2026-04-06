#!/bin/bash 


LOG_DIR="../logs"
# --- Function Definitions ---

count_info() {
    local file=$1
    local count=$(grep -c "INFO" "$file")
    echo "  [INFO]  : $count"
}
count_warn() {
    local file=$1
    local count=$(grep -c "WARN" "$file")
    echo "  [WARN]  : $count"
}
count_error() {
    local file=$1
    local count=$(grep -c "ERROR" "$file")
    echo "  [ERROR] : $count"
}


for log_file in $LOG_DIR/sat-*.log
do
    if [ -f "$log_file" ]; then
        # Print the filename clearly
        echo "Processing: $(basename "$log_file")"
        
        # Call our functions, passing the current file as an argument
        count_info "$log_file"
        count_warn "$log_file"
        count_error "$log_file"
        
        echo "----------------------------------"
    fi
done

echo "Analysis Complete."	
