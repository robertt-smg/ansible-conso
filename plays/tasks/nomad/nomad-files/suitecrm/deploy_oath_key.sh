#!/bin/bash
echo "Start $(date) $0"

if [ -d /bitnami/suitecrm/public/legacy/Api/V8/OAuth2 ]; then

    if [ -f /src/certs/OAuth2/public.key ]; then
        cp /src/certs/OAuth2/public.key /bitnami/suitecrm/public/legacy/Api/V8/OAuth2/public.key
    fi
    if [ -f /src/certs/OAuth2/private.key ]; then
        cp /src/certs/OAuth2/private.key /bitnami/suitecrm/public/legacy/Api/V8/OAuth2/private.key
    fi
    chown daemon:daemon /bitnami/suitecrm/public/legacy/Api/V8/OAuth2/*.key
    chmod 0600 /bitnami/suitecrm/public/legacy/Api/V8/OAuth2/private.key
fi
cd /bitnami/suitecrm
composer install