#!/bin/bash

set -e

# move to example
cd $(dirname $0)/../

configs=$(cat dub.json | jq -r ".configurations | .[] | .name")
echo $configs

dub add-local ..

function on_exit() {
  dub remove-local ..
}
trap on_exit EXIT

dub build ros2_d:msg_gen --force
dub run ros2_d:msg_gen -- .dub/packages
# build
for c in $configs; do
  dub build -c $c
done
