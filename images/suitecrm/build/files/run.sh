#!/bin/bash

echo "Waiting for MySQL Database ${SUITECRM_DATABASE_HOST} $(date) ..."
/usr/bin/wait-for.sh -t "0" "${SUITECRM_DATABASE_HOST}:3306" "--" "/usr/bin/sleep" "15"
 
echo "Starting bitnami suitecrm server $(date) ..."
exec "/opt/bitnami/scripts/suitecrm/entrypoint.sh" $*