#!/bin/bash

echo "Starting JOC Agent ... $(date)"
lighttpd -f /etc/lighttpd/conf-enabled/00-healthweb.conf

exec /usr/local/bin/entrypoint.sh $*