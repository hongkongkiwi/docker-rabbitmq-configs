#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
  # need this for a mac since it doesn't have timeout
  brew install coreutils ;
  alias timeout=gtimeout
fi

docker-compose up -d rabbit
wait-for-it/wait-for-it.sh localhost:15672 -- echo "rabbit is up"
docker-compose up --build worker
