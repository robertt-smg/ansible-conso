#!/bin/bash
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"

source ${SCRIPTPATH}/../../lib/up.sh $*

CERT_DIR=$(realpath --relative-to="$SCRIPTPATH" "$CERT_DIR")
VM_NAME=FTI-TST-APP1
VMName=FTI-TST-APP1
VMPassword=$DefaultGuestAdminPassword
VMMacAddress=00155D1AED42
VMIpAddress=192.168.121.242
VMImageVersion=22.04

is_windows

function run() {
    hyper_v_build
}
win_sudo_me $0 $*
