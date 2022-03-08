#!/bin/bash

set -e
set -o pipefail
set -x

. ./lib.sh
parse_args "$0" "type" "$@"

if ! test -d workdir ; then
	node --experimental_worker ./genie-toolkit/dist/tool/genie.js init-project \
	  --developer-key 88c03add145ad3a3aa4074ffa828be5a391625f9d4e1d0b034b445f18c595656 \
	  --type $type \
	  workdir
fi

if [ $type == "basic" ] ; then 
	if ! test -f workdir/dadjoke.tar.xz ; then
		pushd workdir >/dev/null
		wget https://almond-static.stanford.edu/research/tutorials/dadjoke.tar.xz
		popd >/dev/null
	fi

	if ! test -d workdir/com.icanhazdadjoke ; then 
		pushd workdir >/dev/null
		tar -xf dadjoke.tar.xz
		make everything/schema.tt
		popd >/dev/null
	fi

	if ! test -d devices/com.icanhazdadjoke ; then
		mkdir -p devices
		ln -s ${PWD}/workdir/com.icanhazdadjoke ./devices/com.icanhazdadjoke
	fi

	if ! test -f workdir/dadjoke-model-basic.tar.xz ; then
		pushd workdir > /dev/null
		wget https://almond-static.stanford.edu/research/tutorials/models/dadjoke-basic.tar.xz
		popd > /dev/null
	fi

	if ! test -d workdir/everything/models/dadjoke-basic ; then
		pushd workdir > /dev/null
		mkdir -p everything/models/dadjoke-basic && tar -vxf dadjoke-basic.tar.xz -C everything/models/dadjoke-basic
		popd > /dev/null
	fi
else
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

	if ! test -f workdir/yelp-dialogue.tar.xz ; then
		pushd workdir > /dev/null
		wget https://almond-static.stanford.edu/research/tutorials/models/yelp-dialogue.tar.xz
		popd > /dev/null
	fi

	if ! test -d workdir/everything/models/yelp-dialogue ; then
		pushd workdir > /dev/null
		mkdir -p everything/models/yelp-dialogue && tar -vxf yelp-dialogue.tar.xz -C everything/models/yelp-dialogue
		popd > /dev/null
	fi
fi



