#!/bin/bash

docker stop $(docker ps -a | grep myrabbitmq | awk '{print $1}')
