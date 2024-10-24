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

# Optional Steps/Usability Notes
I've moved the saves into an external volume linked to the FactorioTest directory /saves. To have the server host something other than a basic map, you can place an initial save zip file in here. To copy it from a PC you can use scp in the Windows command line to transfer the file over. Open the saves folder in Explorer, right-click, "Open in Terminal" and do something like `scp savefile.zip linuxuser@linuxipaddress:/home/FactorioTest/`. You'll need to move the file into the /saves folder on the server side, as that will require sudo permissions to edit the volume.

Mods are handled very similiarly to moving the save over. Download them on your local machine in game or through the mods site (https://mods.factorio.com). Go to %AppData%\factorio, open the folder in Terminal, `scp -r mods linuxuser@linuxipaddress:/home/`. You'll need to move the files into the /mods folder on the server side, as that will require sudo permissions to edit the volume. This move can be done en masse with `sudo cp -a ~/mods/. ~/FactorioTest/mods` ENSURE ALL MODS ARE COMPATIBLE WITH THE RELEASE THE SERVER IS ON, otherwise the server will fail to start. 

Cloud Saves
I've added an incredibly basic rclone script here, it just installs it and starts the configurator. rclone has a very friendly interface for setting up a connection to a cloud provider, and they have ample documentation on how to get that configured. I would suggest setting up a cronjob to copy the server save over at a regular interval. It should be as simple as putting a script file like:
`rclone copy ..fill/in/path/to/FactorioTest/saves "NameOfrcloneRemoteConnection:/LocationInRemoteConnection"
` into the appropriate cronjob folder, or setting up a crontab if you want it to run other than hourly or daily. 

Public Connections
If you want the server to be publically available, you will need to set up port forwarding on your router to the server. There are plenty of guides available on the process. 

# To Do
- break server-settings into a volume so users don't need to build a new image (ideally)
- see if I can publish an image so I can have a light "create container only" version of this
- see about automating updates, if I can't tell if a version changes then maybe default to nightly new containers? - could break the server if mods aren't compatible with the new release though, could be possible to have it check to see if the server start command failed, and if so either relocate or delete the mods.
- see about automating mod updates (refer to https://github.com/astevens/factorio-mod-updater), similarly would need to be a scheduled event to be hands off without breaking things
