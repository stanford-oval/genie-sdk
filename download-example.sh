#!/bin/bash

set -e
set -o pipefail
set -x

if ! test -d workdir ; then
	node --experimental_worker ./genie-toolkit/dist/tool/genie.js init-project \
	  --developer-key 88c03add145ad3a3aa4074ffa828be5a391625f9d4e1d0b034b445f18c595656  \
	  workdir
fi

if ! test -f workdir/yelp.tar.xz ; then
	pushd workdir >/dev/null
	wget https://almond-static.stanford.edu/research/tutorials/yelp.tar.xz
	popd >/dev/null
fi

if ! test -d workdir/com.yelp ; then 
	pushd workdir >/dev/null
	tar -xf yelp.tar.xz
	make everything/schema.tt
	popd >/dev/null
fi

if ! test -d devices/com.yelp ; then
	mkdir -p devices
	ln -s ${PWD}/workdir/com.yelp ./devices/com.yelp
fi

if ! test -f workdir/baseline.tar.xz ; then
	pushd workdir > /dev/null
	wget https://almond-static.stanford.edu/research/tutorials/baseline.tar.xz
	popd > /dev/null
fi

if ! test -d workdir/everything/models/baseline ; then
	pushd workdir > /dev/null
	mkdir -p everything/models/baseline && tar -vxf baseline.tar.xz -C everything/models/baseline
	popd > /dev/null
fi