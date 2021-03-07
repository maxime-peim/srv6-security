#!/bin/bash

#docker-compose down
docker-compose up -d node1 node2 node3 node4
#docker-compose run ansible setup-1-interfaces.yaml
#docker-compose run ansible setup-2-sid-definition.yaml
#docker-compose run ansible setup-3-sid-connectivity.yaml
#docker-compose run ansible setup-4-srv6-policies.yaml
docker-compose up -d anx

docker-compose exec node1 apt update
docker-compose exec node1 apt install -y python3 python3-pip
docker-compose exec node1 python3 -m pip install scapy