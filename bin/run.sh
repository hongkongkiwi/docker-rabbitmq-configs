#!/bin/bash

SILENT=$1

./bin/stop.sh $SILENT
./bin/remove.sh $SILENT
./bin/build.sh
docker run -d -p 5672:5672 -p 15672:15672 --name rabbitmq-docker rabbitmq-docker
git submodule update
../wait-for-rabbitmq-docker/wait-for-rabbitmq-docker.sh rabbitmq-docker
