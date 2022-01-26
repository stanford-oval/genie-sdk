#!/usr/bin/env bash

set -e
set -x
set -o pipefail

pushd thingpedia-common-devices >/dev/null
exec ./scripts/setup-ha-virtual-devices.js main universe
popd