#!/bin/bash
echo "Waiting for MySQL Server ${DATASOURCES_DEFAULT_HOST} ... $(date)"

/usr/bin/wait-for.sh -t "0" "${DATASOURCES_DEFAULT_HOST}:3306" "--" "/usr/bin/sleep" "15"

echo "Starting JOC Server ... $(date)"

/opt/sos-berlin.com/js7/joc/install/joc_install_tables.sh

exec /usr/local/bin/entrypoint.sh $*