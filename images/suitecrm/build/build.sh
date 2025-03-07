#!/bin/bash
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"
 
IMAGE_NAME=suitecrm IMAGE_TAG=8 IMAGE_TAG_BUILD=${IMAGE_TAG} source ${SCRIPTPATH}/../../../lib/build.sh $*

