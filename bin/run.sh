#!/bin/bash

./bin/stop.sh --silent
./bin/remove.sh --silent
./bin/build.sh
docker run -d -p 5672:5672 -p 15672:15672  --name rabbitmq-docker rabbitmq-docker
