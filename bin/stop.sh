#!/bin/bash

SILENT=false

if [[ "$1" == "--silent" ]]; then
  SILENT=true
fi

log() {
  if [ "$SILENT" = false ]; then
    echo $1
  fi
}

if docker ps | grep rabbitmq-docker 2>/dev/null >&2; then
  log "Stopping docker container rabbitmq-docker"
  docker stop $(docker ps | grep rabbitmq-docker | awk '{print $1}')
else
  log "Could not find running docker container rabbitmq-docker"
  if docker ps -a | grep rabbitmq-docker 2>/dev/null >&2; then
    log "Container rabbitmq-docker exists but not running"
  fi
fi
