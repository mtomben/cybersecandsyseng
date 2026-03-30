#!/bin/bash

echo -n "Total log entries: " > ../reports/system_summary.txt
cat ../logs/*.log | wc -l >> ../reports/system_summary.txt
echo -n "Total ERROR events: " >> ../reports/system_summary.txt
grep ERROR ../logs/*.log | wc -l >> ../reports/system_summary.txt
echo -n "Total WARN events: " >> ../reports/system_summary.txt
grep WARN ../logs/*.log | wc -l >> ../reports/system_summary.txt

echo -n "Total INFO events: " >> ../reports/system_summary.txt
grep INFO ../logs/*.log | wc -l >> ../reports/system_summary.txt

