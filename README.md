# Creating a Factorio Server In Docker

This repo is a learning project for me to create a Docker container that is running a Factorio server. You likely want to use this wider used script image instead for functionality : https://github.com/factoriotools/factorio-docker/tree/master

A big thanks to u/Germis for a solid write up on how to get a headless server running on a bare metal system : https://www.reddit.com/r/factorio/comments/6qo2ge/guide_setting_up_an_ubuntu_headless_server/

This set of scripts exists to 
1. Pull down the latest version of Factorio Headless Server for Linux
2. Take those files and put them into a debian:slim image
3. Create a working container from that image, that is now a functional Factorio server

The scripts were made on and for an Ubuntu 24.04 LTS server, the dockerfile and docker-compose.yml file should be OS agnostic but you'll need to build the Factorio server files another way if you are on a different OS. This also assumes docker is already installed.

# Step 1 - Configure the server-settings.json
Before you build the image we need to get the server-settings.json filled out. Set the game name, description, your account information, etc, before building the image.

# Step 2 - Build the Factorio server files
Build might be a strong word, but we needs the files to run the Factorio dedicated server and need a save file made. Running the BuildInitialFactorio.sh script will get those ready in this repository folder, which is where the docker files expects them.

# Step 3 - Actually Build The Server
You can either run build.sh (builds the image) and run.sh (turns the image into a container) seperately or run b, which does both sequentially. After that completes, the container should be up and the server should be functional.


# Upcoming changes
- Currently these aren't accessible online, I need to troubleshoot that. They show in the game list but you can't connect.
- Phase 2, trying to add rclone to sync the save file from the server to cloud storage.
