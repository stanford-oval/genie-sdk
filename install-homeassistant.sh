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
	echo "THE TERMINAL IS GOING TO CLOSE, REOPEN IT AND START AGAIN THIS SCRIPT"
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

test -d ./ha/homeassistant-venv || mkdir -p ./ha/homeassistant-venv
test -d ./ha/homeassistant-config || ( mkdir -p ./ha/homeassistant-config && cp -r ./thingpedia-common-devices/test/data/homeassistant/* ./ha/homeassistant-config/ )

python3 -m venv ./ha/homeassistant-venv
source ./ha/homeassistant-venv/bin/activate
python3 -m pip install wheel

pip3 install 'homeassistant==2022.6.6'

exec python3 -m homeassistant -c "./ha/homeassistant-config" &

this_pid=$!

echo
echo "wait 60 seconds for Home Assistant to install itself and set up"

sleep 60

echo
echo "Set virtual devices"
echo

read -p "Press key to continue.. " -n1 -s
exec ./thingpedia-common-devices/scripts/setup-ha-virtual-devices.js main universe

kill -9 $(($this_pid))

deactivate

echo
echo "SETUP COMPLETE"
echo

read -p "Press key to exit.. " -n1 -s
exit