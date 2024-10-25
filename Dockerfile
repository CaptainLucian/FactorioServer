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
#not opt/factorio
#not /factorio
#COPY factorio.service /etc/systemd/system
COPY /ServerFiles/server-settings.json /opt/factorio/data/server-settings.json

SHELL ["/bin/bash", "-c"]

RUN apt install ufw -y
RUN apt install fail2ban -y
#RUN apt install ufw -y
#RUN ufw allow openssh
RUN ufw allow 34197/udp
#RUN ufw enable

CMD /opt/factorio/bin/x64/factorio --server-settings /opt/factorio/data/server-settings.json --start-server-load-latest --console-log /opt/Factorio.log
