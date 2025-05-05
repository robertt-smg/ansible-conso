#!/bin/bash

echo "Waiting for MySQL Database ${SUITECRM_DATABASE_HOST} $(date) ..."
/usr/bin/wait-for.sh -t "0" "${SUITECRM_DATABASE_HOST}:3306" "--" "/usr/bin/sleep" "15"

# Execute all shell scripts in /docker-entrypoint-init.d
if [ -d "/docker-entrypoint-init.d" ]; then
  for script in /docker-entrypoint-init.d/*.sh; do
    if [ -f "$script" ]; then
      echo "Executing $script..."
      . "$script"
    fi
  done
fi

if [ "$XDEBUG" == "1" ]; then
  . /usr/bin/install_xdebug.sh
fi

echo "Starting bitnami suitecrm server $(date) ..."
exec "/opt/bitnami/scripts/suitecrm/entrypoint.sh" $*