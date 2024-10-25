#Starting from base debian image
FROM debian:stable-slim
WORKDIR /opt

RUN apt-get update && apt-get install -y bash

#Exposing Factorio's ports
EXPOSE 34197/udp 
EXPOSE 27015/tcp 

#Adding a user to run the service, may not be needed?
ARG USER=gamemaster
ARG GROUP=factorio

#taking my deployed server files and shoving them into this image
COPY factorio factorio
COPY /ServerFiles/server-settings.json /opt/factorio/data/server-settings.json
COPY ./factorio-mod-loader.sh /opt/
COPY ./StartServer.sh /opt/

SHELL ["/bin/bash", "-c"]

RUN apt install ufw -y
RUN apt install fail2ban -y
#RUN apt install ufw -y
#RUN ufw allow openssh
RUN ufw allow 34197/udp
#RUN ufw enable
RUN apt install jq -y
RUN apt install wget -y

ENTRYPOINT /opt/StartServer.sh
