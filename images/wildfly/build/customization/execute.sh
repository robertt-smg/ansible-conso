#!/bin/bash

# Usage: execute.sh [WildFly mode] [configuration file]
#
# The default mode is 'standalone' and default configuration is based on the
# mode. It can be 'standalone.xml' or 'domain.xml'.

JBOSS_HOME=/opt/jboss/wildfly
JBOSS_CLI=$JBOSS_HOME/bin/jboss-cli.sh
JBOSS_MODE=${1:-"standalone"}
JBOSS_CONFIG=${2:-"$JBOSS_MODE.xml"}

function wait_for_server() {
  until `$JBOSS_CLI -c "ls /deployment" &> /dev/null`; do
    sleep 1
  done
}

echo "=> Change Logger to DEBUG /opt/jboss/standalone/configuration/$JBOSS_CONFIG)"

#sed -i -E '/<root-logger>/ n; s/INFO/DEBUG/' /opt/jboss/wildfly/standalone/configuration/$JBOSS_CONFIG
#sed -i -E '/periodic-rotating-file-handler/ n; s/path="server.log"/path="neocore.log"/' /opt/jboss/wildfly/standalone/configuration/$JBOSS_CONFIG
sed -i -E '/periodic-rotating-file-handler/ n; s/yyyy-MM-dd/yyyy-MM-dd_HH/' /opt/jboss/wildfly/standalone/configuration/$JBOSS_CONFIG
sed -i -E '/<\/periodic-rotating-file-handler>/a <logger category="de.airquest.neo.core.basics.crs"><level name="DEBUG"/></logger>' /opt/jboss/wildfly/standalone/configuration/$JBOSS_CONFIG
sed -i -E '/<\/periodic-rotating-file-handler>/a <logger category="xxclient.XXClient"><level name="DEBUG"/></logger>' /opt/jboss/wildfly/standalone/configuration/$JBOSS_CONFIG


cat /opt/jboss/wildfly/standalone/configuration/$JBOSS_CONFIG

echo "=> Starting WildFly server"
$JBOSS_HOME/bin/$JBOSS_MODE.sh -c $JBOSS_CONFIG > /dev/null &

echo "=> Waiting for the server to boot"
wait_for_server

echo "=> Executing the commands"
$JBOSS_CLI -c --file=`dirname "$0"`/commands.cli

echo "=> Shutting down WildFly"
if [ "$JBOSS_MODE" = "standalone" ]; then
  $JBOSS_CLI -c ":shutdown"
else
  $JBOSS_CLI -c "/host=*:shutdown"
fi

rm /opt/jboss/wildfly/standalone/configuration/standalone_xml_history/current/standalone.v1.xml

