#!/usr/bin/env bash
set -e

address=$STORJ_ADDRESS
if [[ $* == *--update* ]]; then
  echo "updating..."
  docker pull storjlabs/storagenode:arm
fi

if [[ $* == *--ngrok* ]]; then
  echo "using ngrok"
  ngrok_pid=$(ps -e|grep ngrok|cut -d" " -f1)
  if [[ -z $ngrok_pid ]]; then
    ngrok start storj &
    ngrok_pid=$?
    sleep 2
  fi

  trap "kill $ngrok_pid" ERR INT 
  address=$(curl -s http://localhost:4040/api/tunnels|jq .tunnels[0].public_url|sed "s,tcp://,,")
fi

echo "external address: $address"
name=storagenode
container_id=$(docker ps -qaf name=$name)

if [[ $container_id != "" ]]; then
  (docker stop $name)
  docker rm $name
fi

docker run -d -p 28967:28967 \
    -e WALLET="0x31d2d7950F156D8994E808914d528f0Ad035A73e" \
    -e EMAIL="bryan@storj.io" \
    -e ADDRESS="$address" \
    -v "/home/alarm/.local/share/storj/identity/storagenode":/app/identity \
    -v "/run/mount/sda1":/app/config \
    --name $name storjlabs/storagenode:arm

if [[ $* == *-f* ]]; then
  docker logs -f $name
fi
