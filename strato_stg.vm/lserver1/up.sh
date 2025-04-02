#!/bin/bash
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"

source ${SCRIPTPATH}/../../lib/up.sh $*

CERT_DIR=$(realpath --relative-to="$SCRIPTPATH" "$CERT_DIR")
VM_NAME=SMG-STG-L01
VMName=SMG-STG-L01
VMPassword=$DefaultGuestAdminPassword
VMMacAddress=00155D1ABC21
VMIpAddress=172.16.115.21
VMImageVersion=24.04
VMProcessorCount=2
is_windows

function run() {
    hyper_v_build
}
win_sudo_me $0 $*
