#!/bin/bash

set -e
set -o pipefail
set -x

. ./lib.sh
parse_args "$0" "nlp_server" "$@"

if ! test -d ./.home ; then
	mkdir .home
	cat > .home/prefs.db <<EOF
{
  "developer-dir": "${PWD}/devices"
}
EOF
fi

export THINGENGINE_HOME=./.home
[ "${nlp_server}" = "local" ] && export THINGENGINE_NLP_URL=http://127.0.0.1:8400
exec node ./genie-server/dist/main.js
