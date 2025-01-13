#!/bin/bash
set -x
echo $0 $*

HAPROXY_HOST_ADMIN="127.0.0.1:9999"

ls -al ${RENEWED_LINEAGE}

FULLCHAIN_PATH="${RENEWED_LINEAGE}/fullchain.pem"
PRIVKEY_PATH="${RENEWED_LINEAGE}/privkey.pem"
CERT_PATH="/etc/letsencrypt/live/server.pem"

cat "${FULLCHAIN_PATH}" "${PRIVKEY_PATH}" > "${CERT_PATH}"
cp ${CERT_PATH} /usr/local/etc/haproxy/certs/live/server.pem
cp ${CERT_PATH} /var/www/html/.ssl/server.pem

echo -e "set ssl cert /usr/local/etc/haproxy/certs/live/server.pem <<\n$(cat ${CERT_PATH})\n" | socat tcp-connect:${HAPROXY_HOST_ADMIN} -
echo "show ssl cert" | socat tcp-connect:${HAPROXY_HOST_ADMIN} -
echo "commit ssl cert /usr/local/etc/haproxy/certs/live/server.pem" | socat tcp-connect:${HAPROXY_HOST_ADMIN} -