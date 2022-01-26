#!/usr/bin/env bash

set -e
set -x
set -o pipefail

install_node() {
	echo "About to install nvm and nodejs 14"
	wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
	\. $HOME/.nvm/nvm.sh --no-use
	nvm install 14
}

install_deps_dnf() {
	echo "About to install git, make, gettext, g++, pulseaudio, python3"
	sudo dnf -y install git make gettext gcc-c++ pulseaudio-libs-devel python3-pip python3.9
}

install_deps_ubuntu() {
	echo "About to install git, make, gettext, curl, python3"
	sudo apt -y install git make gettext g++ curl libpulse-dev python3-pip python3.9
}

install_deps_debian() {
	echo "About to install git, make, gettext, curl, python3"
	sudo apt -y install git make gettext g++ curl libpulse-dev python3-pip python3.9 apt-transport-https 
}

install_deps() {
	install_node
	if grep -qE "ID(_LIKE)?=.*fedora.*" /etc/os-release ; then
		install_deps_dnf
	elif grep -qE "ID(_LIKE)?=.*ubuntu.*" /etc/os-release ; then
		install_deps_ubuntu
	elif grep -qE "ID(_LIKE)?=.*debian.*" /etc/os-release ; then
		install_deps_debian
	else
		echo "Cannot detect the running distro. Please install dependencies using your package manager."
		exit 1
	fi
}

check_deps() {
	for dep in git node npm make g++ msgfmt python3.9 ; do
		if ! which $dep >/dev/null 2>&1 ; then
			return 1
		fi
	done
	return 0
}

if ! check_deps ; then
	install_deps
fi

if ! test -d genie-toolkit ; then
	git clone https://github.com/stanford-oval/genie-toolkit
	pushd genie-toolkit >/dev/null
	git checkout wip/fix-make
	npm ci
	popd >/dev/null
fi

venv_activate() {
	if [[ -n "${VIRTUAL_ENV}" ]] ; then
		deactivate
	elif [[ -n "${CONDA_DEFAULT_ENV}" ]] ; then 
		CONDA_VERSION=$(cut -d ' ' -f 2 <<< "$(conda -V)")
		VERSION_NUM=$(cut -d '.' -f 1,2 <<< "$CONDA_VERSION")
		if [[ "`echo "${VERSION_NUM} < 4.6" | bc`" -eq 1 ]]; then
			conda init bash
			source deactivate
		else 
			conda init bash
			conda deactivate 
		fi
	fi

	python3 -m pip install --user virtualenv
	python3 -m virtualenv .virtualenv/genie --python=$(which python3.9)
	source .virtualenv/genie/bin/activate
}

if ! test -d genienlp ; then
	git clone https://github.com/stanford-oval/genienlp

	venv_activate
	pip install --upgrade pip	
	echo $(which python)
	pip install 'ray[serve]==1.6.0'
	pushd genienlp
	pip install -e .
	pip install tensorboard
	python -m spacy download en_core_web_sm
	popd
fi

if ! test -d genie-server ; then
	git clone https://github.com/stanford-oval/genie-server
	pushd genie-server >/dev/null
	npm ci
	popd
fi

if ! test -d thingpedia-common-devices ; then 
	git clone https://github.com/stanford-oval/thingpedia-common-devices
	pushd genie-server > /dev/null
	npm ci 
	popd
fi