#!/bin/bash
# based HEAVILY off of JensForstmann's work here: https://github.com/JensForstmann/Factorio-Mod-Loader
#. $(dirname "$0")/factorio-mod-loader.env

#Setting the mods folder to the default for this build
MODS_FOLDER=/opt/factorio/mods
#Pulling the username and token from the server settings
USERNAME=$(cat /opt/factorio/data/server-settings.json | jq -r '.username')
TOKEN=$(cat /opt/factorio/data/server-settings.json | jq -r '.token')

#using jq to pull the mod names instead of the script's original grep solution
enabled_mods=$(jq -r '.mods | .[] | select(.enabled==true) | select(.name != null) | .name' $MODS_FOLDER/mod-list.json)
#removing base game files from the mod folder, at best they fail to do anything
#at worst they break the server
enabled_mods=$(echo "$enabled_mods" | sed s/"base"//)
enabled_mods=$(echo "$enabled_mods" | sed s/"elevated-rails"//)
enabled_mods=$(echo "$enabled_mods" | sed s/"quality"//)
enabled_mods=$(echo "$enabled_mods" | sed s/"space-age"//)

IFS=$'\n'
for mod in $enabled_mods
do
        echo $mod: get info...
        mod_info=$(wget -O - -o /dev/null "https://mods.factorio.com/api/mods/$mod")
        download_url=$(echo "$mod_info" | sed 's/"download_url":"/\n/g' | tail -1 | sed 's/".*//g')
        echo $mod: download_url: $download_url
        file_name=$(echo "$mod_info" | sed 's/"file_name":"/\n/g' | tail -1 | sed 's/".*//g')
        echo $mod: file_name: $file_name
        if [[ -f "$MODS_FOLDER/$file_name" ]];
        then
                echo $mod: already exist, skip downloading...
        else
                wget -O "$MODS_FOLDER/$file_name" -o /dev/null "https://mods.factorio.com/$download_url?username=$USERNAME&token=$TOKEN"
                if [[ $? -ne 0 ]];
                then
                        echo $mod: FAILED DOWNLOADING
                        echo $mod: try again:
                        wget -O "$MODS_FOLDER/$file_name" "https://mods.factorio.com/$download_url?username=$USERNAME&token=$TOKEN"
                fi
        fi
done
unset IFS

disabled_mods=$(jq -r '.mods | .[] | select(.enabled==false) | select(.name != null) | .name' $MODS_FOLDER/mod-list.json)
IFS=$'\n'
for mod in $disabled_mods
do
        echo $mod: Marked as disabled, removing...
        mod_info=$(wget -O - -o /dev/null "https://mods.factorio.com/api/mods/$mod")
        file_name=$(echo "$mod_info" | sed 's/"file_name":"/\n/g' | tail -1 | sed 's/".*//g')
        rm -f $MODS_FOLDER/$file_name
done
unset IFS
echo finished...
