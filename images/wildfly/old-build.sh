#!/bin/bash
source `dirname $0`/../lib/bash_lib.sh
echo -e "\n ------------------------------------------------------------"
echo $0
date

export_env_db_www_aqn

SCRIPT=`readlink -f -- $0`
SCRIPTPATH=`dirname $SCRIPT`

docker rmi -f wildfly-aqneo
IMAGE_BUILD=$(date +"%y%m%d%H%M%S")
docker build --build-arg IMAGE_BUILD=$IMAGE_BUILD --build-arg CURLPROXY=$CURLPROXY --rm  --tag wildfly-aqneo $SCRIPTPATH/wildfly/

if ok "Start image ? ($VERSION)"
then
	$SCRIPTPATH/docker_dev_start.sh
fi

VERSION=${1:-"secure"}

if ok "Upload to fti_ticketshop/docker-images ? ($VERSION)"
then
	REV="27.0.31"
	NAME="wildfly-aqneo"
	docker_upload_secure "${REV}" "${NAME}"
	docker_upload_secure "latest-${VERSION}" "${NAME}"
fi
