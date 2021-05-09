#!/bin/bash
REPO=harbor.chlin.tk/vue
CONTAINER=websocket-ui
TAG=$(git rev-parse --short HEAD)-$(date '+%Y%m%d-%H%M') 
DOCKER_IMAGE=$REPO/$CONTAINER:$TAG
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILDROOT=$DIR/..

# init nginx default.conf
rm default.conf
SELF_IP=`ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}' | head -n1`;
# API_IP=$SELF_IP:3002
API_IP=172.17.0.1:3002
# export API_IP=$API_IP
# echo "$(envsubst < default.conf.template)" >> default.conf
while read line
do
  echo $line | sed -e "s/\${API_IP}/$API_IP/g" | \
    sed -e "s/\${REMOTE_IP}/$REMOTE_IP/g" | \
    sed -e "s/\${API_IP}/$API_IP/g" >> default.conf
done < default.conf.template


# Build docker
cd $BUILDROOT
cmd="docker build -t $DOCKER_IMAGE -f $DIR/DockerFile $BUILDROOT"

echo $cmd
eval $cmd


while getopts "P" OPT ; do
  case ${OPT} in
    P)
      cmd="docker push $DOCKER_IMAGE"
      echo $cmd && eval $cmd
      ;;
  esac
done

echo $DOCKER_IMAGE

docker rm -f websocket-ui
docker run --name websocket-ui --restart always -p 3003:3003 -d $DOCKER_IMAGE nginx -g 'daemon off;'
