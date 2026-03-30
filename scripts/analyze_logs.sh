#!/bin/bash

total_entries=$(cat ../logs/*.log | wc -l)
info_count=$(grep INFO ../logs/*.log | wc -l)
warn_count=$(grep WARN ../logs/*.log | wc -l)
error_count=$(grep ERROR ../logs/*.log | wc -l)

e1=$(grep ERROR ../logs/sat-001.log | wc -l)
e2=$(grep ERROR ../logs/sat-002.log | wc -l)

if [ $e1 -gt $e2 ]; then
    less_stable="sat-001"
elif [ $e2 -gt $e1 ]; then
    less_stable="sat-002"
else
    less_stable="Equal stability"
fi

echo "ORION LOG SUMMARY" > ../reports/log_summary.txt
echo "Total log entries: $total_entries" >> ../reports/log_summary.txt
echo "INFO events: $info_count" >> ../reports/log_summary.txt
echo "WARN events: $warn_count" >> ../reports/log_summary.txt
echo "ERROR events: $error_count" >> ../reports/log_summary.txt
echo "Less stable satellite: $less_stable" >> ../reports/log_summary.txt

echo "¡Análisis completo! Revisa reports/log_summary.txt"
