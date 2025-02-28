#!/bin/bash
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"

source ${SCRIPTPATH}/../../../lib/up.sh $*

up