#!/usr/bin/env bash

set -e
set -x
set -o pipefail

. ./lib.sh

venv_activate "ha"

test -d .homeassistant || cp -r ./thingpedia-common-devices/test/data/homeassistant .homeassistant
exec python -m homeassistant -c .homeassistant