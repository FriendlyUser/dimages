#!/bin/bash
# Simple script to repush docker images from one repository to another
# This is done incremently because my images are massive
original_image="grandfleet/dolwarp"
# github packages expects a project and then an image for that project
new_image="friendlyuser/dimages/lwarp_docker"
# Github package registry with a repository - do not use ghcr.io (massive mistake for me)
target_acr="docker.pkg.github.com"
temp_file="image_list.txt"
rm $temp_file

wget -q https://registry.hub.docker.com/v1/repositories/$original_image/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'| awk -F: '{print $3}' >> $temp_file

while read -r line; do
    tag="$line"
    if [[ "$line" == "latest" ]]; then
      echo "Found line latest"
    else
      # docker image push and delete
      docker pull $original_image:$tag
      docker tag $original_image:$tag $target_acr/$new_image:$tag
      docker push $target_acr/$new_image:$tag
      docker image rm $original_image:$tag
      docker image rm $target_acr/$new_image:$tag
    fi
done < "$temp_file"

rm $temp_file