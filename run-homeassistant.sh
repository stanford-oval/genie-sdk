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
echo
echo "Now is possible to start GENIE Assistant to let it connect to Home Assistant"
echo
echo "Open the browser to interact with HomeAssistant (Username = user | Password = password)"
echo
echo
echo "Press any key to close Home Assistant and exit"
echo

read -p "..> " -n1 -s

echo
echo

kill -9 $(($this_pid))

deactivate
