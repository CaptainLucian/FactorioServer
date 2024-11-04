#!/bin/bash
# Script created when then build method was to download the files and then put them into the container
basedir=$(pwd)
echo "Thanks for the write up /u/Gremia!"
#echo "Setting network permissions.."
#sudo ufu allow openssh
#sudo ufw allow 34197/udp
#sudo ufw enable
#echo "Adding botnet blocking..."
#sudo apt-get install -y fail2ban
echo "Downloading the latest headless server..."
wget -c https://factorio.com/get-download/stable/headless/linux64 -O factorio-server.tar.xz
#wget -c https://www.factorio.com/get-download/latest/headless/linux64 -O factorio-server.tar.xz
echo "Preparing files..."
tar xf factorio-server.tar.xz
rm factorio-server.tar.xz
if [ -d $basedir/factorio/saves ]
then
	echo "skipping save creation"
	if [ -z "$( ls -A '$basedir/factorio/saves' )" ]
	then
		$basedir/factorio/bin/x64/factorio --create ./factorio/saves/initial.zip
	fi
else
	echo "creating save folder and initial save"
        mkdir $basedir/factorio/saves
	$basedir/factorio/bin/x64/factorio --create ./factorio/saves/initial.zip
fi
if [ -f /$basedir/factorio/data/server-settings.json ]
then
	echo "server-settings.json already found"
else
	cp $basedir/factorio/data/server-settings.example.json $basedir/factorio/data/server-settings.json
fi
echo "Factorio files are now ready, go to /factorio/data to set up your server-settings"
