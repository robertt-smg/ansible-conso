#!/bin/bash
echo "--------------------------------------------------------------------------"
cat /version.txt

echo "Starting health check web server $(date) ..."
lighttpd -f /etc/lighttpd/conf-enabled/00-healthweb.conf

echo "Starting database server $(date) ..."
exec "/usr/local/bin/docker-entrypoint.sh" $*