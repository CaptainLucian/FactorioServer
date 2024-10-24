#!/bin/bash
# based HEAVILY off of JensForstmann's work here: https://github.com/JensForstmann/Factorio-Mod-Loader
#. $(dirname "$0")/factorio-mod-loader.env
MODS_FOLDER=~/FactorioTest/ServerFiles/mods
USERNAME=$(cat ./ServerFiles/server-settings.json | jq -r '.username')
TOKEN=$(cat ./ServerFiles/server-settings.json | jq -r '.token')

enabled_mods=$(cat "$MODS_FOLDER/mod-list.json" | grep -B 1 '"enabled": true' | grep '"name"' | sed 's/\s*"name":\s*"//' | sed 's/",//' | grep -v base)
IFS=$'\n'
for mod in $enabled_mods;
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
echo finished...
