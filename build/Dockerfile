#Starting from base debian image
FROM debian:stable-slim
WORKDIR /opt

RUN apt-get update && apt-get install -y bash

#Exposing Factorio's ports
EXPOSE 34197/udp 
#EXPOSE 27015/tcp 

#Adding a user to run the service to reduce permissions available
RUN addgroup -gid 8675 factorio
RUN useradd -ms /bin/bash gamemaster -G factorio -u 5505

#Adding required scripts to the image

#Scipt that updates mods in /opt/factorio/mods
COPY ./mod-update-internal.sh /opt/
#Script that downloads and extracts latest Factorio stable server
COPY ./BuildMe.sh /opt/
#Script that runs the download command, mod update command, and then starts the server process
COPY ./StartServer.sh /opt/

# Setting shell to Bash
SHELL ["/bin/bash", "-c"]

# Installing server file download dependencies
#Needed to download files
RUN apt install wget -y 
# Needed to extract the tar.xz the files are in
RUN apt install xz-utils -y
# Needed for networking
RUN apt install ufw -y
# Needed to allow connections
RUN ufw allow 34197/udp
# Needed to retrieve username and token from server-settings.json to download mods
RUN apt install jq -y
# Intended to add security
RUN apt install fail2ban -y


#Old downloading logic Downloading Factorio Server files
#RUN <<EOT bash
#wget -c https://factorio.com/get-download/stable/headless/linux64 -O factorio-server.tar.xz
#RUN wget -c https://www.factorio.com/get-download/latest/headless/linux64 -O factorio-server.tar.xz
#xzcat factorio-server.tar.xz | tar xvf -
#rm factorio-server.tar.xz
#if [ -d /opt/factorio/saves ]
#then
#        echo "skipping save creation"
#        if [ -z "$( ls -A '/opt/factorio/saves' )" ]
#        then
#                /opt/factorio/bin/x64/factorio --create ./factorio/saves/initial.zip
#        fi
#else
#        echo "creating save folder and initial save"
#        mkdir /opt/factorio/saves
#        /opt/factorio/bin/x64/factorio --create ./factorio/saves/initial.zip
#fi
#if [ -f /opt/factorio/data/server-settings.json ]
#then
#        echo "server-settings.json already found"
#else
#        cp /opt/factorio/data/server-settings.example.json /opt/factorio/data/server-settings.json
#fi
#EOT

#Creating directories and managing permissions
RUN mkdir /opt/factorio
RUN mkdir /opt/factorio/data
RUN chown -R 5505:8675 /opt -R

#Changing to a user that has less access. If someone gets into the container that shouldn't they can't do as much
USER gamemaster
#Launching the StartServer script that runs the mod updater and then starts the server process
ENTRYPOINT /opt/StartServer.sh

#Use this entrypoint instead if you need to keep the container running for troubleshooting
#ENTRYPOINT ["tail", "-f", "/dev/null"]
