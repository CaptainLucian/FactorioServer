#!/bin/bash
#sudo docker build -t captainlucian/factorio-server .
sudo docker build --no-cache -t captainlucian/factorio-server:latest -t captainlucian/factorio-server:v1 .
