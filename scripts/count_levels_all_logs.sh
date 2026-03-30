#!/bin/bash
echo "Global summary"
cat ../logs/*.log | cut -d' ' -f3 | sort | uniq -c
