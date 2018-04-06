#!/bin/bash

./bin/stop.sh
docker rm $(docker ps -a | grep myrabbitmq | awk '{print $1}')
docker image rm $(docker images | grep 'myrabbitmq')
