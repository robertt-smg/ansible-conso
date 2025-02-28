#!/bin/bash
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"

IMAGE_NAME=lego_acme NEW_IMAGE_TAG=4.22 source ${SCRIPTPATH}/../../../lib/build.sh $*


