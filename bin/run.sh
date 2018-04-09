#!/bin/bash

SILENT=$1

./bin/stop.sh $SILENT
./bin/remove.sh $SILENT
./bin/build.sh
docker run -d -p 5672:5672 -p 15672:15672 --name rabbitmq-docker rabbitmq-docker
../wait-for-it-mac/wait-for-it-mac.sh localhost:15672
