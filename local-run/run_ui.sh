i#!/bin/bash
# cp test.env .env
SELF_IP=`ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}' | head -n1`;

while getopts "R:I:h" OPT ; do
  echo "$OPT = $OPTARG"
  case ${OPT} in
    R)
      API_IP="$OPTARG";
      ;;
    I)
      PORT="$OPTARG";
      API_IP=$SELF_IP:$PORT;
      ;;
    h)
      echo "Usage: $0 [-I|-H] <remote_ip>";
      echo "    -I : Use local api";
      echo "    -H : Use local auth";
      echo "Example:";
      echo "    ./run_ui.sh -I 8080";
      exit 1
      ;;
  esac
done


echo "SELF_IP  : $SELF_IP";
echo "PORT : $PORT";
echo "API_IP   : $API_IP";



# shift $(expr $OPTIND - 1 )
# if [ "$#" -lt 1 ]; then
#   echo "Parameter erorr"
#   echo "Usage: $0 [-I|-H] <remote_ip>"
#   echo "e.g., "
#   echo " $0 172.16.101.98"
#   exit 1
# else
#   REMOTE_IP=$1
#   echo "Use remote api service: $1"
# fi
# if [[ -z "$AUTH_IP" ]]; then
#   AUTH_IP=$REMOTE_IP
# fi

SELF_IP=`ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}' | head -n1`;
export SELF_IP=$SELF_IP

rm nginx.conf
while read line
do
  echo $line | sed -e "s/\${API_IP}/$API_IP/g" | \
  sed -e "s/\${REMOTE_IP}/$REMOTE_IP/g" >> nginx.conf
done < nginx.conf.ui.template

docker rm -f nginx
cmd="docker-compose -f ./docker-compose.yml up --force-recreate -d nginx"
echo $cmd
eval $cmd
