#!/bin/bash
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"

source ${SCRIPTPATH}/../../lib/up.sh $*

CERT_DIR=$(realpath --relative-to="$SCRIPTPATH" "$CERT_DIR")
VM_NAME=SMG-TST-L02
VMName=SMG-TST-L02
VMPassword=$DefaultGuestAdminPassword
VMMacAddress=00155D1ABC22
VMIpAddress=192.168.121.22

is_windows

function run() {
    hyper_v_build
}
win_sudo_me $0 $*
