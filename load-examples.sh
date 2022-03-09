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

# link skills from thingpedia-common-devices 	
mkdir -p devices
for d in thingpedia-common-devices/main/* ; do 
	if ! test -d devices/$(basename $d) ; then 
		ln -s ${PWD}/thingpedia-common-devices/main/$(basename $d) ${PWD}/workdir/$(basename $d)
		ln -s ${PWD}/thingpedia-common-devices/main/$(basename $d) ./devices/$(basename $d)
	fi
done 

for d in thingpedia-common-devices/universe/* ; do 
	if ! test -d devices/$(basename $d) ; then 
		ln -s ${PWD}/thingpedia-common-devices/universe/$(basename $d) ${PWD}/workdir/$(basename $d)
		ln -s ${PWD}/thingpedia-common-devices/universe/$(basename $d) ./devices/$(basename $d)
	fi
done 

# generate manifest with all skills
pushd workdir >/dev/null
make everything/schema.tt
popd >/dev/null