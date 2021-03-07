#!/bin/bash
docker-compose down
./prepare.sh
./quick-setup.sh
./topology.sh