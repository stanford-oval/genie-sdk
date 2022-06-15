#!/bin/bash

set -e

source ./ha/homeassistant-venv/bin/activate

echo
echo "Starting Home Assistant"
echo

exec python3 -m homeassistant -c "./ha/homeassistant-config" &
this_pid=$!

echo "The HA PID is $this_pid"
echo
echo "Press any key to close Home Assistant and exit"
echo
echo

read -p "..> " -n1 -s

echo
echo

kill -9 $(($this_pid))

deactivate
