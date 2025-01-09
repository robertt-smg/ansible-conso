#!/bin/sh
set -x
echo $0 $*
# Check if socat is installed, if not, install it
if ! command -v socat &> /dev/null; then
    echo "socat not found, installing..."
    apk add socat
fi
set
ls -al ${RENEWED_LINEAGE}
FULLCHAIN_PATH="${RENEWED_LINEAGE}/fullchain.pem"
PRIVKEY_PATH="${RENEWED_LINEAGE}/privkey.pem"
CERT_PATH="/etc/letsencrypt/live/server.pem"

cat "${FULLCHAIN_PATH}" "${PRIVKEY_PATH}" > "${CERT_PATH}"

echo -e "set ssl cert /usr/local/etc/haproxy/certs/server.pem <<\n$(cat ${CERT_PATH})\n" | socat tcp-connect:${HAPROXY_HOST_ADMIN} -
echo "show ssl cert" | socat tcp-connect:${HAPROXY_HOST_ADMIN} -
echo "commit ssl cert /usr/local/etc/haproxy/certs/server.pem" | socat tcp-connect:${HAPROXY_HOST_ADMIN} -