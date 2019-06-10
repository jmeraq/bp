#!/bin/sh

for line in `cat app/ips.txt`
do
  ssh-keyscan "$line" >> /root/.ssh/known_hosts
  ssh ubuntu@"$line" "sudo docker pull jmeraq/microservice-bp:$1"
  ssh ubuntu@"$line" "sudo docker rm -f microservice-bp"
  ssh ubuntu@"$line" "sudo docker run --name microservice-bp -p 80:80 -dti jmeraq/microservice-bp:$1"
done
