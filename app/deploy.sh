#!/bin/bash
input="ips.txt"
while IFS= read -r line
do
  ssh -i "/home/jmeraq/.ssh/id_rsa" ubuntu@"$line" "sudo docker pull jmeraq/microservice-bp:$1"
  ssh -i "/home/jmeraq/.ssh/id_rsa" ubuntu@"$line" "sudo docker rm -f microservice-bp"
  ssh -i "/home/jmeraq/.ssh/id_rsa" ubuntu@"$line" "sudo docker run --name microservice-bp -p 8081:8081 -dti jmeraq/microservice-bp:$1"
done < "$input"