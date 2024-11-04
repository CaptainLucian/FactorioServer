#!/bin/bash
sudo docker-compose -f docker-compose.yml up -d
sudo chown -R 5505:8675 ./ServerFiles/saves
sudo chown -R 5505:8675 ./ServerFiles/mods
sudo chown -R 5505:8675 ./ServerFiles/server-settings.json
