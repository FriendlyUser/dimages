#!/bin/bash
# Simple script to repush docker images from one repository to another
# This is done incremently because my images are massive
original_image="grandfleet/dolwarp"
# github packages has a strange way of having images, you can have
new_image="friendlyuser/dimages/lwarp_docker"
target_acr="gcr.io"
temp_file="image_list.txt"
rm $temp_file

wget -q https://registry.hub.docker.com/v1/repositories/$original_image/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'| awk -F: '{print $3}' >> $temp_file

while read -r line; do
    tag="$line"
    if [[ "$line" == "latest" ]]; then
      echo "Found line latest"
    else
      # docker image push and delete
      echo "$line"
      docker pull $original_image:$tag
      docker tag $original_image:$tag $target_acr/$new_image:$tag
      docker push $target_acr/$new_image:$tag
      docker image rm $original_image:$tag
    fi
done < "$temp_file"

# variable=$(awk 'BEGIN { ORS="" } { print p"\047"$0"\047"; p=", " } END { print "\n" }' image_list.txt)
# for i in $variable; do
#   echo $i
# done
exit
# Old approach with hardcoded numbers
# for i in v{0.65,0.66,0.67}; do
#   u="${u:+$u, }$i"
# done
# echo "$u"

exit
docker login
target_acr="gcr.io"