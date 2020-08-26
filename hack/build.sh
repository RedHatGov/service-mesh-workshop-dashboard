#! /usr/bin/env bash

# change these
CONTAINER_IMAGE=service-mesh-workshop-dashboard
DOCKERFILE_DIR=

function print_usage() {
  echo "usage: $0 [-l (local|quay)] [-p QUAY_PROJECT] [-t CONTAINER_TAG] [-- BUILD_ARGS]"
}

# parse args
while [ $# -gt 0 ]; do
  case "$1" in
    -l|--location=*)
      if [ "$1" = '-l' ]; then
        shift
        LOCATION="$1"
      else
        LOCATION=$(echo "$1" | cut -d= -f2-)
      fi
      ;;
    -p|--project=*)
      if [ "$1" = '-p' ]; then
        shift
        QUAY_PROJECT="$1"
      else
        QUAY_PROJECT=$(echo "$1" | cut -d= -f2-)
      fi
      ;;
    -t|--tag=*)
      if [ "$1" = '-t' ]; then
        shift
        CONTAINER_TAG="$1"
      else
        CONTAINER_TAG=$(echo "$1" | cut -d= -f2-)
      fi
      ;;
    --)
      shift
      break
      ;;
    *)
      print_usage >&2
      exit 127
      ;;
  esac
  shift
done

cd $(dirname $(realpath $0))/../$DOCKERFILE_DIR

# some defaults
if [ -f .quay_creds -a -z "$LOCATION" ]; then
  LOCATION=quay
  . .quay_creds
elif [ -z "$LOCATION" ]; then
  LOCATION=local
fi
if [ -z "$QUAY_PROJECT" ]; then
  QUAY_PROJECT=redhatgov
fi
if [ -z "$CONTAINER_TAG" ]; then
  CONTAINER_TAG=latest
fi

# docker/podman problems
if ! which docker &>/dev/null; then
  if which podman &>/dev/null; then
    function docker() { podman "${@}" ; }
  else
    echo "No docker|podman installed :(" >&2
    exit 1
  fi
fi

# build
case $LOCATION in
  local)
    docker build "${@}" -t quay.io/$QUAY_PROJECT/$CONTAINER_IMAGE:$CONTAINER_TAG .
  ;;
  quay)
    # designed to be used by travis-ci, where the docker_* variables are defined
    if [ -z "$DOCKER_PASSWORD" -o -z "$DOCKER_USERNAME" ]; then
        echo "Requires DOCKER_USERNAME and DOCKER_PASSWORD variables to be exported." >&2
        exit 1
    fi
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin quay.io || exit 2

    docker build "${@}" -t quay.io/$QUAY_PROJECT/$CONTAINER_IMAGE:$CONTAINER_TAG . || exit 3
    docker push quay.io/$QUAY_PROJECT/$CONTAINER_IMAGE:$CONTAINER_TAG || exit 4
  ;;
  *)
    print_usage >&2
    exit 127
  ;;
esac
