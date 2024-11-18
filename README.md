# Overview

This repo is a learning project for me to create a Docker container that is running a Factorio server. You likely want to use this wider used script image instead for functionality: https://github.com/factoriotools/factorio-docker/tree/master

A big thanks to u/Germis for a solid write up on how to get a headless server running on a bare metal system : https://www.reddit.com/r/factorio/comments/6qo2ge/guide_setting_up_an_ubuntu_headless_server/ . Also a shout out to JenForstman's Factorio-Mod-Loader that I modified for this https://github.com/JensForstmann/Factorio-Mod-Loader. (collapsed it to one file, incorporated jq, excluded new items from Space Age that cause the server to break when explicitly downloaded as mod)

This set of scripts exists to 
1. Create an image of a Factorio server
2. Create a container from that image that is now a functional Factorio server

The scripts were made on and for an Ubuntu 24.04 LTS server, the dockerfile and docker-compose.yml file should be OS agnostic. These directions also assume that docker is already installed.

The intent is that anything that needs to be user edited or persistant lives in the /ServerFiles subdirectory. 

# Creating the Server

## Step 1 - Configure the Server
Before you build the image we need to get the server-settings.json filled out, a default version is provided in the FactorioServer/ServerFiles directory. Set the game name, description, your account information, etc, and save. Lastly edit the docker-compose.yml file if you want to update the time zone. 

## Step 2 - Deploy the Server
Run the /FactorioServer/run.sh script or a similiar command `sudo docker-compose -f docker-compose.yml up -d` to use what is in the docker-compose.yml file to deploy the image you built. Use `sudo docker ps` to confirm that the container is running. Note that if you did not use the run.sh script, you will encounter permissions issues on the directories that are volumes. Part of that script is to give the user running the container permissions to update those locations.

# Optional Steps/Usability Notes
## Saves
I've moved the saves into an external volume linked to the FactorioTest directory ServerFiles/saves. To have the server host something other than a basic map, you can place an initial save zip file in here. To copy it from a PC you can use scp in the Windows command line to transfer the file over. Open the saves folder in Explorer, right-click, "Open in Terminal" and do something like `scp savefile.zip linuxuser@linuxipaddress:/home/linuxuser/FactorioServer/`. You'll need to move the file into the /saves folder on the server side, as that will require sudo permissions to edit the volume.

## Mods
Upon container creation the mods listed in the mod-list.json are downloaded and updated. This file is set in the volume ServerFiles/mods and can either be edited directly or replaced through copying in a file with the desired mods. If you do use the copy method, exactly like the saves you'll need to copy the file over like `scp mod-list.json linuxuser@linuxipaddress:/home/linuxuser/FactorioServer/` and then move it from /FactorioServer into the /ServerFiles directory on the server, as it will require sudo permissions to add files to the volume.

Ensure that all mods set to be used are compatible with the server or the container will immediately stop as it will have failed to run the server process. To troubleshoot from this scenario, disable mods from the mod-list.json file and restart the container `sudo docker restart the_factory` to get the server into a working state again.

## Cloud Saves
I've added an incredibly basic rclone script here, it just installs it and starts the configurator. rclone has a very friendly interface for setting up a connection to a cloud provider, and they have ample documentation on how to get that configured. I would suggest setting up a cronjob to copy the server save over at a regular interval. It should be as simple as putting a script file like:
`rclone copy ..fill/in/path/to/FactorioServer/ServerFiles/saves "NameOfrcloneRemoteConnection:/LocationInRemoteConnection"` into the appropriate cronjob folder, or setting up a crontab if you want it to run other than hourly or daily. If you intend running the copy/sync with a cronjob, either configure rclone as root or move/copy rclone's configuration file to root's .config folder so that it can run.

## Public Connections
If you want the server to be publically available, you will need to set up port forwarding on your router to the server. There are plenty of guides available on the process. 

# Building Your Own Image
If you would rather create your own image, you can use the scripts provided in the build directory to do so. If you would rather use the experimental builds for your server or setting the server to download a specific version, you would want to update the BuildMe.sh script to download the appropriate files.

## Step 1 - Configure the Server
Before you build the image we need to get the server-settings.json filled out, a default version is provided in the FactorioServer/ServerFiles directory. Set the game name, description, your account information, etc, and save. Lastly edit the docker-compose.yml file if you want to update the time zone. 

## Step 2 - Build the Factorio server files
Run the build.sh script or a similiar command from the /FactorioServer/build directory `sudo docker build --no-cache -t captainlucian/factorio-server:latest -t` to create the image to deploy. 

## Step 3 - Deploy the Server
Run the /FactorioServer/run.sh script or a similiar command `sudo docker-compose -f docker-compose.yml up -d` to use what is in the docker-compose.yml file to deploy the image you built. Use `sudo docker ps` to confirm that the container is running. Note that if you did not use the run.sh script or alter how the container is being run (as gamemaster vs as root), you will encounter permissions issues on the directories that are volumes. Part of that script is to give the user running the container permissions to update those locations.

# WSL
If you intend to run the set up in a WSL set up, you will run into the need for some additional set up. By default, after installing Docker the Docker Daemon will not be started when you start the WSL instance. To correct this, you will need to either start the service on a one off basis `sudo service docker start` or set it up in a /etc/wsl.conf file.

The run.sh script will need to be edited from docker-compose to docker compose to create the container.

The map creation command is failing in WSL hosted instances, so a save will need to be manually added for it to work.

# Ansible
If you would rather deploy the Factorio Server to a Linux server remotely, you can use the ansible playbook provided in the ansible directory. Inside of the ansible directory is the template for an inventory file, update the ansible_host value with your intended server, and update the ansible_user value with the user for that server. If you intend to user a username/password authentication, you will need to add the ansible_sudo_pass variable to the inventory file, or if you would prefer to do SSH key auth, refer to the security section below. Run the LocalDependencies.sh script to install Ansible and the community collections and roles used within the playbook. Once that has been done, run  `ansible-playbook playbook.yml -i ~/FactorioServer/ansible/inventory.yml` from the ansible directory to start the deployment process. If everything was configured correctly, the server should now be functional! ** This isn't true just yet, I'm just pre-emptively updating the documenation while other parts are fresh in my head.

## Securing the Ansible Inventory
To make the Ansible inventory.yml file more secure there are two major options, to use a key vault (for username/password authentication) or to use SSH keys. You can further lock down the security on the endpoint server through the SSH key method, so that would be my suggestion as it is also simplier, though if you no longer have the key you will no longer be able to remotely log into the server at all. 

### Configure the keys
To start with, you'll need to generate keys on your local system that you are using to ssh into the endpoint server. You can do this with a simple command `ssh-keygen -t ed25519`, though if desired you could use other keygen options. From here, use the built in command ssh-copy-id `ssh-copy-id username@remote_host` to copy your public key to the server. You may need to update the permissions on those files on the endpoint server, ssh to it (hopefully you will not be prompted for a password), and then run `chmod 700 ~/.ssh` and `chmod 600 ~/.ssh/authorized_keys` to set the permissions. You should now be able to ssh into the endpoint server without providing a password!

### Granting sudo Access And Locking Down The System
In order for the Ansible script to do everything it needs to, it needs to utilize sudo permissions. To do that with ONLY ssh key authentication the user on the endpoint server will need to be configured to utilize sudo access without needing a password, which isn't ideal for security but can be mitigated with further changes. 

On the endpoint server, do `sudo nano /etc/sudousers` and add your user under the sudo entry, listed like "user ALL=(ALL) NOPASSWD: ALL". After saving that edit, confim that sudo actions no longer need authentication. To reduce the security concerns over no longer requiring a password, remove the ability to ssh into the server through password authentication. On the endpoint server, run `sudo nano /etc/ssh/sshd_config` and change #PasswordAuthentication yes to #PasswordAuthentication no. Then run `sudo nano /etc/ssh/sshd_config.d/50-cloud-init.conf` and set password authentication to no. Lastly restart SSH with `sudo service ssh restart` and your server should no longer be able to be ssh'd to without the key. 


# To Do
- see about automating updates, if I can't tell if a version changes then maybe default to nightly new containers? - https://wiki.factorio.com/Download_API
 -- I should still poke at that, though the new methodology doesn't make it as needed. I could have a script to auto restart the container when needed though.

- get the ansible playbook to download the required files from this repository onto the host machine (just the ServerFiles directory and files)
