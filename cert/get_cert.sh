#!/bin/bash
#set -x
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"

AUTODNS_CONTEXT_DEMO=1
AUTODNS_CONTEXT_PROD=4

# Check if config.secret exists
if [ ! -f "${SCRIPTPATH}/config.secret" ]; then
    echo "Error: config.secret not found in ${SCRIPTPATH}"
    exit 1
fi

source "${SCRIPTPATH}/config.secret"

# Check if lego is installed
if ! command -v lego &> /dev/null; then
    echo "Error: lego is not installed. Please install it first."
    exit 1
fi

# Check if domain argument is provided
if [ -z "${ALL_DOMAINS}" ]; then
    echo "Usage: ALL_DOMAINS=<domain1,domain2,domain3...>"
    echo "Example: ALL_DOMAINS=example.com,www.example.com"
    exit 1
fi

CERT_PATH="${SCRIPTPATH}/certificates"

# Convert comma-separated domains into -d arguments
DOMAIN_ARGS=""
IFS=',' read -ra DOMAINS <<< "$ALL_DOMAINS"
for domain in "${DOMAINS[@]}"; do
    # Trim whitespace from domain
    domain=$(echo "$domain" | tr -d '[:space:]')
    if [ -n "$domain" ]; then
        DOMAIN_ARGS="$DOMAIN_ARGS -d $domain"
    fi
done

# Create certificates directory if it doesn't exist
mkdir -p "$CERT_PATH"

if [ "${USE_STAGING:-0}" -eq "1" ]; then
    STAGING="-server https://acme-staging-v02.api.letsencrypt.org/directory"
else
    STAGING=""
fi

# Run lego with AutoDNS provider for easyssl stage
lego --email "${EMAIL}" \
     --dns autodns \
     --path "${CERT_PATH}" \
     $STAGING \
     --accept-tos \
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