#!/bin/bash

set -e
set -o pipefail
set -x

# init workdir
if ! test -d workdir ; then
	node --experimental_worker ./genie-toolkit/dist/tool/genie.js init-project \
	  --developer-key 88c03add145ad3a3aa4074ffa828be5a391625f9d4e1d0b034b445f18c595656  \
	  workdir
fi

# copy skill data
pushd workdir >/dev/null
cp -r ../thingpedia-common-devices/main/* .
cp -r ../thingpedia-common-devices/universe/* .
make everything/schema.tt
popd >/dev/null

# install skills 	
mkdir -p devices
for d in thingpedia-common-devices/main/* ; do 
	if ! test -d devices/$(basename $d) ; then 
		pushd workdir/$(basename $d) >/dev/null
		npm ci
		popd >/dev/null
		ln -s ${PWD}/workdir/$(basename $d) ./devices/$(basename $d)
	fi
done 

for d in thingpedia-common-devices/universe/* ; do 
	if ! test -d devices/$(basename $d) ; then 
		pushd workdir/$(basename $d) >/dev/null
		npm ci
		popd >/dev/null
		ln -s ${PWD}/workdir/$(basename $d) ./devices/$(basename $d)
	fi
done 