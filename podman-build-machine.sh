#!/bin/bash 
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"
export MSYS_NO_PATHCONV=0

if podman machine list | grep -q podman-machine-default; then
    podman machine stop podman-machine-default
    podman machine rm podman-machine-default
    taskkill -f -im win-sshproxy.exe
fi

podman machine init --cpus=4 --memory=8192
podman machine set --rootful
podman machine start

echo "Connecting podman default root machine ..."
CONNECTION=$(podman system connection list|grep podman-machine-default-root)
URI=$(echo $CONNECTION|grep podman-machine-default-root|awk '{print $2}')
IDENT=$(echo $CONNECTION|grep podman-machine-default-root|awk '{print $3}')

user=$(echo "$URI" | sed 's|.*//\([^@]*\)@.*|\1|')
host=$(echo "$URI" | awk -F[@:] '{print $3}')
port=$(echo "$URI" | awk -F: '{print $3}' | awk -F/ '{print $1}')
PW=$(pwd)

scp -i $IDENT -P $port -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -o LogLevel=ERROR  ${SCRIPTPATH}/podman-init.sh $user@$host:/root/podman-init.sh
#ssh -i $IDENT -p $port -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -o LogLevel=ERROR $user@$host
podman machine ssh "bash -x /root/podman-init.sh PRE"
podman machine stop
podman machine start
podman machine ssh "bash -x /root/podman-init.sh POST"

