#!/bin/bash
# Downloads the latest stable server files
wget -c https://factorio.com/get-download/stable/headless/linux64 -O factorio-server.tar.xz
# This is the permenent link for the latest experiemental files
#wget -c https://www.factorio.com/get-download/latest/headless/linux64 -O factorio-server.tar.xz
# Extracts the server files
xzcat factorio-server.tar.xz | tar xvf -
rm factorio-server.tar.xz
# Checks to see if the saves directory exists and if it is empty, will create a new save if it is
if [ -d /opt/factorio/saves ]
then
        echo "skipping save creation"
        if [ -z "$( ls -A '/opt/factorio/saves' )" ]
        then
                /opt/factorio/bin/x64/factorio --create /opt/factorio/saves/initial.zip
        fi
else
        echo "creating save folder and initial save"
        mkdir /opt/factorio/saves
        /opt/factorio/bin/x64/factorio --create /opt/factorio/saves/initial.zip
fi
if [ -f /opt/factorio/data/server-settings.json ]
then
        echo "server-settings.json already found"
else
        cp /opt/factorio/data/server-settings.example.json /opt/factorio/data/server-settings.json
fi
