#!/bin/bash
cat ../logs/*.log | cut -d' ' -f3 | sort | uniq -c > ../reports/level_summary.txt
echo "Report saved"
