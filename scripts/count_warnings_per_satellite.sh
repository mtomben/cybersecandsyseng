#!/bin/bash

echo "Orion Warning Report" 
echo "Warnings Sat-001"
grep WARN ../logs/sat-001.log | wc -l
echo "Warnings Sat-002"
grep WARN ../logs/sat-002.log | wc -l 

