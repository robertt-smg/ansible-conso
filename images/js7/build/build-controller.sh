#!/bin/bash
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"

IMAGE_NAME=js7-controller IMAGE_TAG=2-7-3 IMAGE_TAG_BUILD=${IMAGE_TAG} DOCKERFILE=Dockerfile.controller source ${SCRIPTPATH}/../../../lib/build.sh $*

