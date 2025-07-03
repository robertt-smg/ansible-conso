#!/bin/bash

echo "Starting health check web server $(date) ..."
lighttpd -f /etc/lighttpd/conf-enabled/00-healthweb.conf

echo "Starting Controller ... $(date)"
exec /usr/local/bin/entrypoint.sh $*