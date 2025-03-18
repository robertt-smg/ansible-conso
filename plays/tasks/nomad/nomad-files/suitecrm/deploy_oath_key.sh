#!/bin/bash

[ -f /src/certs/OAuth2/public.key ] && [ -d /bitnami/suitecrm/Api/V8/OAuth2 ] && cp /src/certs/OAuth2/public.key /bitnami/suitecrm/Api/V8/OAuth2/public.key
[ -f /src/certs/OAuth2/private.key ] && [ -d /bitnami/suitecrm/Api/V8/OAuth2 ] && cp /src/certs/OAuth2/private.key /bitnami/suitecrm/Api/V8/OAuth2/private.key

