#!/bin/bash
#
# Copyright (c) 2018 Cisco Systems
#
# Author: Steven Barth <stbarth@cisco.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo Bringing up containers...
docker-compose up -d                                # Bring up topology

echo Waiting for Ansible to complete...
docker-compose logs -f ansible

echo Configuring Ubuntu networking...

echo Node 1 networking
# Node 1: Replace IP address
docker-compose exec node1 ip addr replace fd10::1/64 dev vpp
# Node 1: Set route
docker-compose exec node1 ip route add fd40::/64 via fd10::10
docker-compose exec node1 ip route add fd30::/64 via fd10::10
docker-compose exec node1 ip route add fd20::/64 via fd10::10

echo Node 2 networking
# Node 2: Replace IP address
docker-compose exec node2 ip addr replace fd20::1/64 dev vpp
# Node 2: Set route
docker-compose exec node2 ip route add fd10::/64 via fd20::20
docker-compose exec node2 ip route add fd30::/64 via fd20::20
docker-compose exec node2 ip route add fd40::/64 via fd20::20

echo Node 3 networking
# Node 3: Replace IP address
docker-compose exec node3 ip addr replace fd30::1/64 dev vpp
# Node 3: Set route
docker-compose exec node3 ip route add fd10::/64 via fd30::30
docker-compose exec node3 ip route add fd20::/64 via fd30::30
docker-compose exec node3 ip route add fd40::/64 via fd30::30

echo Node 4 networking
# Node 4: Replace IP address
docker-compose exec node4 ip addr replace fd40::1/64 dev vpp
# Node 4: Set route
docker-compose exec node4 ip route add fd10::/64 via fd40::40
docker-compose exec node4 ip route add fd20::/64 via fd40::40
docker-compose exec node4 ip route add fd30::/64 via fd40::40

echo Sleeping 5 seconds
sleep 5

echo Running pings between Node 1 and Node 4 over SRv6 tunnel
docker-compose exec node1 ping6 -c 3 fd40::1
docker-compose exec node4 ping6 -c 3 fd10::1

cat <<EOF


All done. You can do the following to explore this setup further:
    Open a shell to a Ubuntu container:         docker-compose exec node1 bash
    Open the VPP debug CLI of a node:           docker-compose exec node1 vppctl
    Access NETCONF API with a browser:          http://localhost:9269
                                                NETCONF device:         node1:2831
                                                Username & Password:    admin
    Access the telemetry data explorer:         http://localhost:8888/sources/0/chronograf/data-explorer
    Teardown this demo:                         docker-compose down
EOF
