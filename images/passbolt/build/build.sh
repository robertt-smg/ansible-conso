#!/bin/bash
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"

function cleanup() {
    echo ${FUNCNAME[0]}
    ## we remove ansible as this is just a image
    purge_ansible_ubuntu
}
source ${SCRIPTPATH}/../../../lib/build.sh $*

