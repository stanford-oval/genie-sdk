#!/bin/bash

set -e
set -o pipefail

. ./lib.sh
parse_args "$0" "nlu_model" "$@"

set -x

exec node --experimental_worker ./genie-toolkit/dist/tool/genie.js server \
  --nlu-model "file://workdir/everything/models/${nlu_model}/" \
  --thingpedia "workdir/everything/schema.tt" 
