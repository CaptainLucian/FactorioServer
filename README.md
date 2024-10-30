# Creating a Factorio Server In Docker

This repo is a learning project for me to create a Docker container that is running a Factorio server. You likely want to use this wider used script image instead for functionality and more recent images : https://github.com/factoriotools/factorio-docker/tree/master

A big thanks to u/Germis for a solid write up on how to get a headless server running on a bare metal system : https://www.reddit.com/r/factorio/comments/6qo2ge/guide_setting_up_an_ubuntu_headless_server/ . Also a shout out to JenForstman's Factorio-Mod-Loader that I modified for this https://github.com/JensForstmann/Factorio-Mod-Loader. (collapsed it to one file, incorporated jq, excluded new items from Space Age that cause the server to break when explicitly downloaded as mod)

This set of scripts exists to 
1. Create an image of a Factorio server
2. Create a container from that image that is now a functional Factorio server

The scripts were made on and for an Ubuntu 24.04 LTS server, the dockerfile and docker-compose.yml file should be OS agnostic. These directions also assume that docker is already installed.

The intent is that anything that needs to be user edited or persistant lives in the /ServerFiles subdirectory. 

# Step 1 - Configure the Server
Before you build the image we need to get the server-settings.json filled out, a default version is provided in the FactorioServer/ServerFiles directory. Set the game name, description, your account information, etc, and save. Lastly edit the docker-compose.yml file if you want to update the time zone. 

# Step 2 - Build the Factorio server files
Run the build.sh script or a similiar command from the /FactorioServer/build directory `sudo docker build --no-cache -t captainlucian/factorio-server:latest -t` to create the image to deploy. 

# Step 3 - Deploy the Server
Run the /FactorioServer/run.sh script or a similiar command `sudo docker-compose -f docker-compose.yml up -d` to use what is in the docker-compose.yml file to deploy the image you built. Use `sudo docker ps` to confirm that the container is running.

# Optional Steps/Usability Notes
## Saves
I've moved the saves into an external volume linked to the FactorioTest directory ServerFiles/saves. To have the server host something other than a basic map, you can place an initial save zip file in here. To copy it from a PC you can use scp in the Windows command line to transfer the file over. Open the saves folder in Explorer, right-click, "Open in Terminal" and do something like `scp savefile.zip linuxuser@linuxipaddress:/home/linuxuser/FactorioServer/`. You'll need to move the file into the /saves folder on the server side, as that will require sudo permissions to edit the volume.

## Mods
There are two methodolgies available to handle mods with this build. 

#1 - Default

By default, you will only be able to access the mod-list.json file that is being used to run the server in the ServerFiles/mods folder. By adding items to the JSON file or disabling mods you can manage what the script will download. When you create the container intially or whenever you restart it, the script (mod-update-internal.sh) will run to update the mods and download any missing mods that are enabled in the list. To authenticate to download the mods, it will require that your server-settings.json file is configured with your token. 

#2 - See full mod folder/run updates externally

The other method for handling mods in this configuration is to change the volume defined in the docker-compose.yml file from covering just the mod-list.json file to covering the entire mods folder. This method requires that mod updates and downloads are handled outside of container through the factorio-mod-update.sh script, as the user running the container will not have access to delete files within a volume. 

Regardless of method, ensure that all mods set to be used are compatible with the server or the container will immediately stop as it will have failed to run the server process. To troubleshoot from this scenario, disable mods from the mod-list.json file and restart the container `sudo docker restart the_factory` to get the server into a working state again.

## Cloud Saves
I've added an incredibly basic rclone script here, it just installs it and starts the configurator. rclone has a very friendly interface for setting up a connection to a cloud provider, and they have ample documentation on how to get that configured. I would suggest setting up a cronjob to copy the server save over at a regular interval. It should be as simple as putting a script file like:
`rclone copy ..fill/in/path/to/FactorioServer/ServerFiles/saves "NameOfrcloneRemoteConnection:/LocationInRemoteConnection"` into the appropriate cronjob folder, or setting up a crontab if you want it to run other than hourly or daily. If you intend running the copy/sync with a cronjob, either configure rclone as root or move/copy rclone's configuration file to root's .config folder so that it can run.

## Public Connections
If you want the server to be publically available, you will need to set up port forwarding on your router to the server. There are plenty of guides available on the process. 

# To Do
- see about automating updates, if I can't tell if a version changes then maybe default to nightly new containers? - could break the server if mods aren't compatible with the new release though, could be possible to have it check to see if the server start command failed, and if so either relocate or delete the mods.
- see about automating pushing new images to docker, making them is already done
-- Alternatively, see if I can get a setup made that will just always deploy the current latest stable release every time, so the image doesn't need to be changed out. Would need to be specified in the docker-compose.yml file, if possible, though that's after the rights granted get reduced to a regular user
