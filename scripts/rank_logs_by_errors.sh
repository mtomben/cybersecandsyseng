for file in ../logs/*.log 
do 
	count=$(grep -c "Error" "$file") 
	echo "$count: $file"

done | sort -rn | cut -d':' -f2- | awk '{print $1}'
