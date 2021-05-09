#!/bin/bash
REPO=harbor.emotibot.com/bfop
CONTAINER=chat-room-ui
TAG=base
DOCKER_IMAGE=$REPO/$CONTAINER:$TAG

DOCKER_IMAGE=harbor.emotibot.com/bfop/chat-room-ui:488d49f_20210105121056

echo $DOCKER_IMAGE

docker rm -f webosocket-ui

docker run --name webosocket-ui --restart always -p 8201:80 -d $DOCKER_IMAGE nginx -g 'daemon off;'
