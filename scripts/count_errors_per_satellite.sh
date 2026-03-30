#!/bin/bash

echo "Orion Error Report"
echo "Errors Sat-001"
grep ERROR ../logs/sat-001.log | wc -l
echo "Erros Sat-002"
grep ERROR ../logs/sat-002.log | wc -l 
