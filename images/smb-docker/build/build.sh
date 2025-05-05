#!/bin/bash
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"

IMAGE_NAME=smb-docker NEW_IMAGE_TAG=1.0 source ${SCRIPTPATH}/../../../lib/build.sh $*


