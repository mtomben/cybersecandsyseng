
max_events=0
noisiest_sat=""


for file in ../logs/sat-*.log
do
  
    warn_count=$(grep -c "WARN" "$file")
    error_count=$(grep -c "ERROR" "$file")
   
  
    total_non_info=$((warn_count + error_count))
    
  
    current_sat=$(basename "$file")
    
  
    echo "$current_sat: $total_non_info eventos (WARN: $warn_count, ERROR: $error_count)"
    
    if [ "$total_non_info" -gt "$max_events" ]; then
        max_events=$total_non_info
        noisiest_sat=$current_sat
    fi
done


echo "Noisest satellite is $noisiest_sat with $max_events events"
