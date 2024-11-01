#Starting from base debian image
FROM debian:stable-slim
WORKDIR /opt

RUN apt-get update && apt-get install -y bash

#Exposing Factorio's ports
EXPOSE 34197/udp 
#EXPOSE 27015/tcp 

#Adding a user to run the service to reduce permissions available
ARG USER=gamemaster
ARG GROUP=factorio
RUN addgroup -gid 8675 factorio
RUN useradd -ms /bin/bash gamemaster -G factorio -u 5505

#taking my deployed server files and shoving them into this image
#COPY factorio factorio
#COPY ./server-settings.json /opt/factorio/data/server-settings.json
COPY ./mod-update-internal.sh /opt/
COPY ./StartServer.sh /opt/

SHELL ["/bin/bash", "-c"]

RUN apt install wget -y
RUN apt install xz-utils -y

#Downloading Factorio Server files
RUN <<EOT bash
wget -c https://factorio.com/get-download/stable/headless/linux64 -O factorio-server.tar.xz
#RUN wget -c https://www.factorio.com/get-download/latest/headless/linux64 -O factorio-server.tar.xz
xzcat factorio-server.tar.xz | tar xvf -
rm factorio-server.tar.xz
if [ -d /opt/factorio/saves ]
then
        echo "skipping save creation"
        if [ -z "$( ls -A '/opt/factorio/saves' )" ]
        then
                /opt/factorio/bin/x64/factorio --create ./factorio/saves/initial.zip
        fi
else
        echo "creating save folder and initial save"
        mkdir /opt/factorio/saves
        /opt/factorio/bin/x64/factorio --create ./factorio/saves/initial.zip
fi
if [ -f /opt/factorio/data/server-settings.json ]
then
        echo "server-settings.json already found"
else
        cp /opt/factorio/data/server-settings.example.json /opt/factorio/data/server-settings.json
fi
EOT
#Preparing network configuration
RUN apt install ufw -y
RUN apt install fail2ban -y
RUN ufw allow 34197/udp
RUN apt install jq -y
#RUN mkdir /opt/factorio
RUN chown gamemaster:factorio /opt -R
#RUN chown gamemaster:factorio /opt/factorio/saves/* -R
#RUN chown gamemaster:gamemaster /opt/factorio -R
#Changing to a user that has less access. If someone gets into the container that shouldn't they can't do as much
USER gamemaster
#Launching the StartServer script that runs the mod updater and then starts the server process
ENTRYPOINT /opt/StartServer.sh

#Use this entrypoint instead if you need to keep the container running for troubleshooting
#ENTRYPOINT ["tail", "-f", "/dev/null"]
