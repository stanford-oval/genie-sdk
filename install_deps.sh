#!/usr/bin/env bash

set -e
set -x
set -o pipefail

# === Mac OSX ===

check_mac_arch() {
	if [ "$(uname -p)" = "intel" ]; then
		echo "Running in Intel arch (Rosetta)"
		eval "$(/usr/local/homebrew/bin/brew shellenv)"
		alias brew='/usr/local/homebrew/bin/brew'
	else
		echo "Running in ARM arch"
		eval "$(/opt/homebrew/bin/brew shellenv)"
		alias brew='/opt/homebrew/bin/brew'
	fi
}

install_mac_deps() {
	for dep in git make gettext g++ curl; do
		if ! which $dep >/dev/null 2>&1 ; then
			echo "Installing: $dep"
			eval "$(brew install ${dep})"
		fi
	done
}


# === Linux ===

install_linux_deps() {
	if grep -qE "ID(_LIKE)?=.*fedora.*" /etc/os-release ; then
		echo "Installing: git, make, gettext, g++, pulseaudio, apt-transport-https"
		sudo dnf -y install git make gettext gcc-c++ pulseaudio-libs-devel apt-transport-https
	elif grep -qE "ID(_LIKE)?=.*ubuntu.*" /etc/os-release ; then
		echo "Installing: git, make, gettext, curl, libpulse, apt-transport-https"
		sudo apt -y install git make gettext g++ curl libpulse-dev apt-transport-https
	elif grep -qE "ID(_LIKE)?=.*debian.*" /etc/os-release ; then
		echo "Installing: git, make, gettext, curl,libpulse, apt-transport-https"
		sudo apt -y install git make gettext g++ curl libpulse-dev apt-transport-https
	else
		echo "Cannot detect the running distro. Please install dependencies using your package manager."
		exit 1
	fi
}

# === NodeJS ===

install_nodejs() {
	echo "Installing: nvm"
	if [[ -n $(nvm -v 2>&1) ]] ; then
		# Download & run the install script with bash, clones the nvm repository into ~/.nvm, updates profile
		wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
		# Loads nvm
		\. $HOME/.nvm/nvm.sh --no-use
	fi
	echo "Installing: node 18"
	nvm install 18
	# Set the default version of node to 18
	nvm alias default 18.12.1
}

# === Run ===

install_deps() {
	SYSTEM="$(uname)"
	if [ "$SYSTEM" = "Darwin" ]; then
		check_mac_arch
		install_mac_deps
		install_nodejs
	elif [ "$SYSTEM" = "Linux" ]; then
		install_linux_deps
		install_nodejs
	fi
}

install_deps