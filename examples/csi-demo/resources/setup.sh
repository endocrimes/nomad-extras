#!/usr/bin/env bash

nomad run $HOME/plugin.nomad
sleep 10
curl -X PUT http://localhost:4646/v1/csi/volume/ -vvv --data @$HOME/create-volume.json
nomad run $HOME/volume.nomad


