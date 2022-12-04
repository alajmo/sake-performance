#!/bin/bash

set -e

function start_containers() {
  # docker run --name sake-test-1 -d -p 10000:22 sake-test >/dev/null &
  # return

  for i in `seq 1 $_NUM_HOSTS`; do
    docker run -d --name "sake-test-$i" -p $((9999 + i)):22 sake-test >/dev/null &

    if ! (( $i % 50 )); then
      echo "${i}/${1}"
      wait
    fi
  done
  wait

  echo "All containers are up"
}

function kill_containers() {
  # TODO: only kill sake-test containers
  local containers=`docker ps -q`
  if [ ! "$containers" = "" ]; then
    docker kill $containers
  fi
}

function __main__() {
  _NUM_HOSTS=500

  if [[ -n $1 ]]; then
    _NUM_HOSTS=$1
  fi

  echo $_NUM_HOSTS

  kill_containers
  docker build -t sake-test .
  start_containers

  sleep infinity
}

trap kill_containers EXIT

__main__ $@
