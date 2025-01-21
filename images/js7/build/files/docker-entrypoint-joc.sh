#!/bin/bash

echo "Starting ... $(date)"
/usr/bin/wait-for.sh -t "0" "${DATASOURCES_DEFAULT_HOST}:3306" "--" "/usr/bin/sleep" "15"

exec /usr/local/bin/entrypoint.sh $*