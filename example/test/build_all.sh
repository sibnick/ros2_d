#!/bin/bash

set -e

# move to ros2_d
cd $(dirname $0)/../../

configs=$(cat example/dub.json | jq -r ".configurations | .[] | .name")
echo $configs

# build
for c in $configs; do
  dub build :example -c $c
done
