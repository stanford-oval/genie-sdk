#!/usr/bin/env bash

set -e
set -x
set -o pipefail

if ! test -d genie-toolkit ; then
	git clone -b wip/levenshtein https://github.com/stanford-oval/genie-toolkit
	pushd genie-toolkit > /dev/null
	git clean -fdx
	npm ci
	npm link
	popd >/dev/null
fi

if ! test -d genie-server ; then
	git clone https://github.com/stanford-oval/genie-server
	pushd genie-server > /dev/null
	git clean -fdx
	npm ci
	popd
fi

if ! test -d thingpedia-common-devices ; then 
	git clone -b wip/special-purpose-agent https://github.com/stanford-oval/thingpedia-common-devices
	pushd thingpedia-common-devices > /dev/null
	npm ci 
	npm link genie-toolkit
	popd
fi