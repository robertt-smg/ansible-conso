#!/bin/bash
SCRIPT=`readlink -f -- $0`
SCRIPTPATH=`dirname $SCRIPT`
#set -x
function cleanup() {
    echo ${FUNCNAME[0]}
    purge_ansible
}
source ${SCRIPTPATH}/../../../lib/build.sh $*

