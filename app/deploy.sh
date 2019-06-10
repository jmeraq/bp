#!/bin/bash
input="app/ips.txt"
while IFS= read -r line
do
  ssh-keyscan "$line" >> /root/.ssh/known_hosts
  ssh -i "/root/.ssh/id_rsa" ubuntu@"$line" "sudo docker pull jmeraq/microservice-bp:$1"
  ssh -i "/root/.ssh/id_rsa" ubuntu@"$line" "sudo docker rm -f microservice-bp"
  ssh -i "/root/.ssh/id_rsa" ubuntu@"$line" "sudo docker run --name microservice-bp -p 80:80 -dti jmeraq/microservice-bp:$1"
done < "$input"