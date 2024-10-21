
#Starting from base debian image
FROM debian:stable-slim
WORKDIR /opt

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
COPY factorio.service /etc/systemd/system
COPY server-settings.json /opt/factorio/data/server-settings.json

CMD /opt/factorio/bin/x64/factorio --server-settings /opt/factorio/data/server-settings.json --start-server-load-latest --console-log /opt/Factorio.log

