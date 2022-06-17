#!/bin/bash

set -e

if [ -d ./thingpedia-common-devices ]
then
	echo
	echo "Thingpedia-common-devices OK"
	echo
	sleep 5
else
	read -n 1 -e -p "Thingpedia-common-devices missing, do you want to run the SDK installation now? (y/n): " INST
	echo
	if [ "$INST" = "y" ] || [ "$INST" = "Y" ]
	then
		echo
	    echo "OK, launching install.sh"
	    echo
		read -p "Press key to continue.. " -n1 -s
		. ./install.sh
	elif [ "$INST" = "n" ] || [ "$INST" = "N" ]
		then
			echo
	    		echo "OK, nothing to do"
	    		echo
			read -p "Press key to exit.. " -n1 -s
			exit 0
		else
			echo
			echo "Wrong choice, retry"
       			echo
			read -p "Press key to exit.. " -n1 -s
			exit 0
	fi
fi

check_os=[`. /etc/os-release; echo "$NAME"`]

echo
echo "This OS is $check_os"
echo

if [[ $check_os == *"Ubuntu"* ]];
then
	echo
    echo "Setting Ubuntu for Home Assistant installation"
    echo
	read -p "Press key to continue.. " -n1 -s
    . ./thingpedia-common-devices/scripts/set-ha-inst-ubuntu.sh
elif [[ $check_os == *"Fedora"* ]];
	then
		echo
    		echo "Setting Fedora for Home Assistant installation"
		echo
    		read -p "Press key to continue.. " -n1 -s
    		. ./thingpedia-common-devices/scripts/set-ha-inst-fedora.sh
	else
    		echo
		echo "OS NOT RECOGNIZED"
    		echo
    		read -p "Press key to exit.. " -n1 -s
    		exit 0
fi

echo
echo "Setting NVM and NODEjs"
echo

sleep 5

if [ -d ~/.nvm ]
then
	echo
	echo "NVM already installed"
	echo
	sleep 5
else
	echo
	echo "About to install NVM"
	echo
    	read -p "Press key to continue.. " -n1 -s
    	wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
fi

. ~/.nvm/nvm.sh --no-use

if [[  $(node -v 2>&1) == v14.18* ]]
then
	echo
	echo "Node.js 14.18 already installed"
	echo
	sleep 5
else
	echo
	echo "Try to install NODEjs 14.18"
	echo
	read -p "Press key to continue.. " -n1 -s
	nvm install 14.18
fi

nvm use 14.18

echo
echo "Setting PyENV"
echo

sleep 5

if [ -d ~/.pyenv ]
then
   	echo
	echo "PyENV already installed"
	echo

	sleep 5
else
	echo
	echo "About to install PyENV"
	echo

	read -p "Press key to continue.. " -n1 -s

	git clone https://github.com/pyenv/pyenv.git ~/.pyenv

	echo
	echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
	echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
	echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
	echo 
	echo "CLOSE THE TERMINAL, REOPEN IT AND START AGAIN THIS SCRIPT (if pyenv will be not found, reboot the system)"
	echo

	read -p "Press key to continue.. " -n1 -s

	exit 0
fi

if [ -d ./ha ]
then
        echo "Home Assistant already set"
        echo
	read -p "Press key to exit.. " -n1 -s
	exit 0
else
	mkdir -p ./ha
fi

test -d  ~/.pyenv/versions/3.9.10 || pyenv install 3.9.10

pyenv global 3.9.10

test -d ./ha/homeassistant-venv || cp -r ./thingpedia-common-devices/test/data/homeassistant/venv ./ha/homeassistant-venv
test -d ./ha/homeassistant-config || cp -r ./thingpedia-common-devices/test/data/homeassistant/conf ./ha/homeassistant-config

echo
echo "SETUP COMPLETE"
echo

read -p "Press key to exit.. " -n1 -s
exit