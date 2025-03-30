#!/bin/bash
#set -x
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"
exec $SCRIPTPATH/../../cook.sh $*