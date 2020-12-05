!#/bin/sh

docker login
docker pull grandfleet/dolwarp -a

original_image="grandfleet/dolwarp"
target_acr="gcr.io"
minimum_version="2.1"
grep_filter="v*|latest"


# Download all images
docker pull $original_image --all-tags

# Get all images published after $minimum_version
# format output to be: 
#   docker tag ORIGINAL_IMAGE_NAME:VERSION TARGET_IMAGE_NAME:VERSION |
#   docker push TARGET_IMAGE_NAME:VERSION
# then filter the result, removing any entries containing words defined on $grep_filter (i.e. rc, beta, alpha, etc)
# finally, execute those as commands
docker images $original_image \
  --format "docker tag {{.Repository}}:{{.Tag}} $target_acr/{{.Repository}}:{{.Tag}} | docker push $target_acr/{{.Repository}}:{{.Tag}}" | 
  grep -vE $grep_filter | 
  bash

 