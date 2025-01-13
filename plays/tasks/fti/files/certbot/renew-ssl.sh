#!/bin/bash
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"
set -x
echo $0 $*

source /etc/haproxy/certbot/.env

certbot certonly ${IS_STAGING} --expand --webroot -w ${WEB_ROOT} ${DOMAIN_LIST} \
    --email ${EMAIL} \
    --agree-tos --non-interactive --agree-tos --no-eff-email --no-redirect \
    --deploy-hook ${SCRIPTPATH}/deploy-ssl.sh
