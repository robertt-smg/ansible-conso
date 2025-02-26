#!/bin/bash
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"

IMAGE_NAME=mariadb DOCKERFILE=Dockerfile.v10-11 source ${SCRIPTPATH}/../../../lib/build.sh $*

