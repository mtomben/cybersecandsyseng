#!/bin/bash
grep WARN logs/*.log | cut -d' ' -f1,2 > reports/warn_timestamps.txt
echo "Timestamps saved"
