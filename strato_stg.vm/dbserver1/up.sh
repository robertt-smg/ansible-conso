#!/bin/bash
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"

source ${SCRIPTPATH}/../../lib/up.sh $*

CERT_DIR=$(realpath --relative-to="$SCRIPTPATH" "$CERT_DIR")
VM_NAME=SMG-TST-DB1
VMName=SMG-TST-DB1
VMPassword=$DefaultGuestAdminPassword
VMMacAddress=00155D1ABC31
VMIpAddress=192.168.218.31
VMImageVersion=22.04

is_windows

function run() {
    hyper_v_build
}
win_sudo_me $0 $*
