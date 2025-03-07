#!/bin/bash
echo "Waiting for MySQL Server ${DATASOURCES_DEFAULT_HOST} ... $(date)"

/usr/bin/wait-for.sh -t "0" "${DATASOURCES_DEFAULT_HOST}:3306" "--" "/usr/bin/sleep" "15"

echo "Starting JOC Server ... $(date)"
exec /usr/local/bin/entrypoint.sh $*