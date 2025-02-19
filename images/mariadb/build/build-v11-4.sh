#!/bin/bash
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"

IMAGE_NAME=mariadb DOCKERFILE=Dockerfile.v11-4 source ${SCRIPTPATH}/../../../lib/build.sh $*

