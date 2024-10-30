#!/bin/bash
sudo docker-compose -f docker-compose.yml up -d
sudo chown -R 5505:8675 ./ServerFiles/saves
