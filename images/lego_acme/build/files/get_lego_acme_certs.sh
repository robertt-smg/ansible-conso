#!/bin/bash
set -x
echo "Start $(date) ..."

SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"

AUTODNS_CONTEXT_DEMO=1
AUTODNS_CONTEXT_PROD=4

function setup() {
    echo ${FUNCNAME[0]}
    # Check if SECRETS_PATH is defined
    if [ -z "${SECRETS_PATH}" ]; then
        echo "Error: SECRETS_PATH environment variable is not defined"
        exit 1
    fi
    # Check if config.secret exists
    if [ ! -f "${SECRETS_PATH}/config.secret" ]; then
        echo "Error: config.secret not found in ${SECRETS_PATH}"
        exit 1
    fi
    source "${SECRETS_PATH}/config.secret"

    # Create certificates directory if it doesn't exist
    # Check if CERT_PATH is defined
    if [ -z "${CERT_PATH}" ]; then
        echo "Error: CERT_PATH environment variable is not defined"
        exit 1
    fi
    [ ! -d ${CERT_PATH} ] && mkdir -p ${CERT_PATH}
    
    # Check if lego is installed
    if ! command -v lego &> /dev/null; then
        echo "Error: lego is not installed. Please install it first.(https://go-acme.github.io/lego)"
        exit 1
    fi

    # Check if domain argument is provided
    if [ -z "${ALL_DOMAINS}" ]; then
        echo "Usage: ALL_DOMAINS=<domain1,domain2,domain3...>"
        echo "Example: ALL_DOMAINS=example.com,www.example.com"
        exit 1
    fi
}
function build_domain_string() {
    echo ${FUNCNAME[0]}
    # Convert comma-separated domains into -d arguments
    DOMAIN_ARGS=""
    FIRST_DOMAIN=""

    IFS=',' read -ra DOMAINS <<< "$ALL_DOMAINS"
    for domain in "${DOMAINS[@]}"; do
        # Trim whitespace from domain
        domain=$(echo "$domain" | tr -d '[:space:]')
        if [ -z "$FIRST_DOMAIN" ]; then
            FIRST_DOMAIN="$domain"
        fi
        if [ -n "$domain" ]; then
            DOMAIN_ARGS="$DOMAIN_ARGS -d $domain"
        fi
    done

    if [ "${USE_STAGING:-0}" -eq "1" ]; then
        STAGING="-server https://acme-staging-v02.api.letsencrypt.org/directory"
    else
        STAGING=""
    fi
}
function get_certs() {
    echo ${FUNCNAME[0]}
    # Run lego with AutoDNS provider for easyssl stage
    lego --email "${EMAIL}" \
        --dns autodns \
        --path "${CERT_PATH}" \
        $STAGING \
        --accept-tos \
        --pem \
        $DOMAIN_ARGS \
        run 

    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo "Certificate successfully generated!"
        echo "Certificates are stored in: ${CERT_PATH}"
    else
        echo "Error: Certificate generation failed with exit code ${exit_code}"
        exit $exit_code
    fi
}

function deploy() {
    echo ${FUNCNAME[0]}
        # Check if socat is installed, if not, install it
    if ! command -v socat &> /dev/null; then
        echo "socat not found, installing..."
        apk add socat
    fi
    CERT_PATH_LIVE="${CERT_PATH}/live"
    [ ! -d  "${CERT_PATH_LIVE}" ] && mkdir -p "${CERT_PATH_LIVE}"
    cp "${CERT_PATH}/${FIRST_DOMAIN}.pem" "${CERT_PATH_LIVE}/server.pem"

    echo -e "set ssl cert ${CERT_PATH_LIVE}/server.pem <<\n$(cat ${CERT_PATH_LIVE}/server.pem)\n" | socat tcp-connect:${HAPROXY_HOST_ADMIN} -
    echo "show ssl cert" | socat tcp-connect:${HAPROXY_HOST_ADMIN} -
    echo "commit ssl cert ${CERT_PATH_LIVE}/server.pem" | socat tcp-connect:${HAPROXY_HOST_ADMIN} -
}
function main() {
    echo ${FUNCNAME[0]}
    setup
    build_domain_string
    get_certs
    [ ! -z "${HAPROXY_HOST_ADMIN}" ] && deploy
}

main