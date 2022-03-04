#!/bin/bash

set -e
set -o pipefail

. ./lib.sh
parse_args "$0" "skill_name type" "$@"

set -x

if ! test -d workdir ; then
	node --experimental_worker ./genie-toolkit/dist/tool/genie.js init-project \
	  --developer-key 88c03add145ad3a3aa4074ffa828be5a391625f9d4e1d0b034b445f18c595656  \
	  --type ${type} \
	  workdir
fi
  
if ! test -d workdir/${skill_name} ; then
	pushd workdir >/dev/null
    node --experimental_worker ../genie-toolkit/dist/tool/genie.js init-device \
	  ${skill_name} \
      --type ${type}
	popd >/dev/null
fi

if ! test -d devices/${skill_name} ; then
	mkdir -p devices
	ln -s ${PWD}/workdir/${skill_name} ./devices/${skill_name}
fi
