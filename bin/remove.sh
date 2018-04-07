#!/bin/bash

./bin/stop.sh "$1"

SILENT=false

if [[ "$1" == "--silent" ]]; then
  SILENT=true
fi

log() {
  if [ "$SILENT" = false ]; then
    echo $1
  fi
}

if docker ps -a | grep rabbitmq-docker 2>/dev/null >&2; then
  log "Removing docker container rabbitmq-docker"
  docker rm $(docker ps -a | grep rabbitmq-docker | awk '{print $1}')
else
  log "Could not find docker container rabbitmq-docker"
fi

if docker images -f "dangling=true" -q 2>/dev/null >&2; then
  log "Removing docker images that are unused (dangling)"
  if [ "$SILENT" = false ]; then
    docker image prune -f
  else
    docker image prune -f 2>&1 >/dev/null
  fi
fi

if docker images | grep rabbitmq-docker 2>/dev/null >&2; then
  log "Removing docker image rabbitmq-docker"
  docker image rm $(docker images | grep rabbitmq-docker | awk '{print $1}')
else
  log "Could not find docker image rabbitmq-docker"
fi
