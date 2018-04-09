#!/bin/bash

SILENT=false

if [[ "$1" == "--silent" ]]; then
  SILENT=true
fi

log() {
  if ! $SILENT; then
    echo $1
  fi
}

run_command() {
  if $SILENT; then
    $1 &>/dev/null
  else
    $1
  fi
}

if docker ps | grep rabbitmq-docker &>/dev/null; then
  log "Stopping docker container rabbitmq-docker"
  run_command "docker stop $(docker ps | grep rabbitmq-docker | awk '{print $1}')"
  exit 0
else
  log "Could not find running docker container rabbitmq-docker"
  if docker ps -a | grep rabbitmq-docker &>/dev/null; then
    log "Container rabbitmq-docker exists but not running"
  fi
  exit 1
fi
