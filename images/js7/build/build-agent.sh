#!/bin/bash
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"

IMAGE_NAME=js7-agent IMAGE_TAG=2-7-3 IMAGE_TAG_BUILD=${IMAGE_TAG} DOCKERFILE=Dockerfile.agent source ${SCRIPTPATH}/../../../lib/build.sh $*

