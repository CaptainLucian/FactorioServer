#!/bin/bash
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
mkdir $basedir/factorio/saves
$basedir/factorio/bin/x64/factorio --create ./factorio/saves/initial.zip
cp $basedir/factorio/data/server-settings.example.json $basedir/factorio/data/server-settings.json
echo "Factorio files are now ready, go to /factorio/data to set up your server-settings"
