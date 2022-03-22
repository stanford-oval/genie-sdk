#!/bin/bash

set -e

test -d ./thingpedia-common-devices && (echo "Thingpedia-common-devices missing" && exit) || . ./install.sh
test -d ./ha && (echo "HomeAssistant already installed" && exit) || mkdir -p ./ha

check_os=[`. /etc/os-release; echo "$NAME"`]

echo "This OS is $check_os"

if [[ $check_os == *"Ubuntu"* ]];
then
    echo "Setting Ubuntu for Home assistant installation"
    sleep 10
    . ./scripts/set-ha-inst-ubuntu.sh
elif [[ $check_os == *"Fedora"* ]];
then
    echo "Setting Fedora for Home assistant installation"
    sleep 10
    . ./scripts/set-ha-inst-fedora.sh
else
    echo "OS NOT RECOGNIZED"
    sleep 15
    exit 0
fi

echo "Setting NVM and NODEjs"
sleep 5

if [[ -n $(nvm -v 2>&1) ]] ; then
        echo "About to install NVM"
        sleep 5

        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
        \. $HOME/.nvm/nvm.sh --no-use
else
        echo "NVM already installed"
fi


echo "About to install NODEjs 14"
sleep 5

nvm install 14.18
nvm use 14.18

echo "Check if PyENV is installed"
sleep 5

test ! -d  ~/.pyenv && ( git clone https://github.com/pyenv/pyenv.git ~/.pyenv && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile && echo "NOW PLEASE CLOSE THE TERMINAL AND REOPEN IT" && sleep 30 && exit ) || echo "PYENV already installed"

test -d  ~/.pyenv/versions/3.9.10 || pyenv install 3.9.10

pyenv global 3.9.10

test -d ./ha/homeassistant-venv || mkdir -p ./ha/homeassistant-venv
test -d ./ha/homeassistant-config || ( mkdir -p ./ha/homeassistant-config && cp -r ./thingpedia-common-devices/test/data/homeassistant/* ./ha/homeassistant-config/ )

python3 -m venv ./ha/homeassistant-venv

source ./ha/homeassistant-venv/bin/activate

python3 -m pip install wheel

pip3 install 'homeassistant==2022.2.5'

hass
echo "wait 30 seconds for Home Assistant to install itself and set up"
sleep 30


pushd thingpedia-common-devices >/dev/null
exec ./thingpedia-common-devices/scripts/setup-ha-virtual-devices.js main universe
popd

#./thingpedia-common-devices/scripts/setup-ha-virtual-devices.js main universe
echo "Set virtual devices"
sleep 15

deactivate

echo "SETUP COMPLETE"
exit

#./scripts/run-home-assistant.sh &

