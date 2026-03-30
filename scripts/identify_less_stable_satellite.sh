#!/bin/bash
e1=$(grep ERROR ../logs/sat-001.log | wc -l)
e2=$(grep ERROR ../logs/sat-002.log | wc -l)

echo "Sat-001 errors: $e1"
echo "Sat-002 errors: $e2"

if [ $e1 -gt $e2 ]; then
    echo "Less stable satellite: sat-001"
elif [ $e2 -gt $e1 ]; then
    echo "Less stable satellite: sat-002"
else
    echo "Both satellites have the same stability."
fi
