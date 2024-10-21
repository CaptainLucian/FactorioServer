#!/bin/bash
echo "Thanks for the write up /u/Gremia!"
echo "Setting network permissions.."
sudo ufu allow openssh
sudo ufw allow 34197/udp
sudo ufw enable
echo "Adding botnet blocking..."
sudo apt-get install -y fail2ban
echo "Downloading the latest headless server..."
wget -c https://www.factorio.com/get-download/latest/headless/linux64 -O factorio-server.tar.xz
echo "Preparing files..."
tar xf factorio-server.tar.xz
rm factorio-server.tar.xz
mkdir ./factorio/saves
./factorio/bin/x64/factorio --create ./factorio/saves/initial.zip
echo "Factorio files are now ready, go to /factorio/data to set up your server-settings"
