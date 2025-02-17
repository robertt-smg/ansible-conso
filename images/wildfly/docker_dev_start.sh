#!/bin/bash
source `dirname $0`/../lib/bash_lib.sh
echo -e "\n ------------------------------------------------------------"
echo $0
date

SCRIPT=`readlink -f -- $0`
SCRIPTPATH=`dirname $SCRIPT`

echo stop wildfly-dev
docker container stop wildfly-dev
echo remove wildfly-dev
docker container rm wildfly-dev
docker rmi -f wildfly-dev
echo start wildfly-dev
#USE_PROXY=" -Dhttp.proxyHost=192.168.33.1 -Dhttp.proxyPort=8888 "
USE_PROXY=""

DB="--add-host=aqdb1.prd.muc01.fti.int:192.168.33.1 --add-host=dev01.inhouse.fti-ticketshop.de:192.168.33.1 --add-host=dev36.inhouse.fti-ticketshop.de:192.168.33.36 --add-host=ts.inhouse.fti-ticketshop.de:10.83.20.146"

echo Using local IP 127.0.0.180 '=>' http://dev180.inhouse.fti-ticketshop.de:8080//neoCore/XmlServlet or dev180.inhouse.fti-ticketshop.de:9990

VERSION=${1:-"latest"}
cd /tmp
mkdir -p $SCRIPTPATH/log

cmd.exe /c "docker run -it $DB -p 127.0.0.180:8080:8080 -p 127.0.0.180:9990:9990 -p 127.0.0.180:8787:8787 --name wildfly-dev -v $SCRIPTPATH/log/wildfly:/opt/jboss/wildfly/standalone/log wildfly-aqneo:$VERSION /opt/jboss/wildfly/bin/standalone.sh $USE_PROXY -Dlog4j2.debug -Dlog4j2.formatMsgNoLookups=true -b 0.0.0.0 -bmanagement 0.0.0.0 --debug 8787"

