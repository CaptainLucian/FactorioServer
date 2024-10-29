#!/bin/bash
sleep 5
/opt/mod-update-internal.sh
sleep 1
/opt/factorio/bin/x64/factorio --server-settings /opt/factorio/data/server-settings.json --start-server-load-latest --console-log /opt/Factorio.log
