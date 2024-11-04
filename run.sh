#!/bin/bash
# Creates a container based on the configuration specified in the docker-compose.yml file
sudo docker-compose -f docker-compose.yml up -d
# Grants permission to the volumes to the gamemaster:factorio user inside the container.
sudo chown -R 5505:8675 ./ServerFiles/saves
sudo chown -R 5505:8675 ./ServerFiles/mods
sudo chown -R 5505:8675 ./ServerFiles/server-settings.json
