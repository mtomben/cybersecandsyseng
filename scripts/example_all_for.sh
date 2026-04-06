#!/bin/bash 

SEARCH_PATTERN=$1

for file in ../logs/*.log
do 
	if [ -f "$file" ]; then 
  	COUNT=$(grep -c "$SEARCH_PATTERN" "$file")
	
        echo "$(basename "$file"): $COUNT"

fi 
done 
