#!/bin/bash
set -e

print_msg() {
	echo -e "\x1b[31;4m${1}\x1b[0m"
}

IMAGE_NAME="$1"
USERNAME="$2"
PASSWORD="$3"

# if [ ! "$#" -lt 1 ]; then
# else
#   print_msg " => ERROR: You must specify the image name.  <="
#   exit 1
# fi

if [ ! -f Dockerfile ]; then
	print_msg "   ERROR: no Dockerfile detected! Create one!"
    # we can create one from a base image... then we don't need to exit
    #echo "FROM <insert base image here??>" >> Dockerfile
    exit 1
fi

#
# Detect docker credentials for pulling private images and for pushing the built image
#
print_msg "=> Loading docker auth configuration"
if [ ! -z "$USERNAME" ] && [ ! -z "$PASSWORD" ]; then
	REGISTRY=$(echo $IMAGE_NAME | tr "/" "\n" | head -n1 | grep "\." || true)
	print_msg "   Logging into $REGISTRY using $USERNAME"
	docker login -u $USERNAME -p $PASSWORD $REGISTRY
elif [ -f ~/.dockercfg ]; then
	print_msg "   Using existing configuration in ~/.dockercfg"
elif [ -d ~/.docker ]; then
	print_msg "   Using existing configuration in ~/.docker"
else
	print_msg "   WARNING: no \$USERNAME/\$PASSWORD or \$DOCKERCFG or \$DOCKER_CONFIG found - unable to load any credentials for pushing/pulling"
fi

#
# Build Image Step
#
print_msg "=> Building *Build Environment* Image"
START_DATE=$(date +"%s")
docker build --rm --force-rm -t this .
END_DATE=$(date +"%s")
DATE_DIFF=$(($END_DATE-$START_DATE))
BUILD="Image built in $(($DATE_DIFF / 60)) minutes and $(($DATE_DIFF % 60)) seconds"

#
# Push Image Step
#
START_DATE=$(date +"%s")
if [ ! -z "$IMAGE_NAME" ]; then
	if [ ! -z "$USERNAME" ] || [ -f ~/.dockercfg ] || [ -f ~/.docker/config.json ]; then
		print_msg "=> Pushing image $IMAGE_NAME"
		docker tag this $IMAGE_NAME
		docker push $IMAGE_NAME && break
		#print_msg "   Pushed image $IMAGE_NAME"
		#print_msg "   Cleaning up images"
		#docker rmi -f $(docker images -q --no-trunc -a) > /dev/null 2>&1 || true
    else
        PUSH="No login for pushing image found. Not pushing image."
        print_msg "   $PUSH"
    fi
else
	PUSH="Skipping push"
	print_msg "   $PUSH"
fi

END_DATE=$(date +"%s")
DATE_DIFF=$(($END_DATE-$START_DATE))
PUSH=${PUSH:-"Image $IMAGE_NAME pushed in $(($DATE_DIFF / 60)) minutes and $(($DATE_DIFF % 60)) seconds"}

#
# Final summary
#
cat <<EOF


Build summary
=============
$BUILD
$PUSH
EOF
