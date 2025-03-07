#!/bin/bash

echo "Waiting for MySQL Database ${DATASOURCES_DEFAULT_HOST} $(date) ..."
/usr/bin/wait-for.sh -t "0" "${DATASOURCES_DEFAULT_HOST}:3306" "--" "/usr/bin/sleep" "15"

[ -d /data/passbolt/etc ] && cp -R /data/passbolt/etc/ /etc/passbolt/ && echo "copied /data/passbolt/etc to /etc/passbolt"
[ -d /gpg ] && ln -s /gpg /etc/passbolt/gpg && echo "created symlink /gpg -> /etc/passbolt/gpg"

if [ -d /jwt ]; then
    [ -n "$(find "/jwt" -mindepth 1 -print -quit)" ] && cp /jwt/* /etc/passbolt/jwt 
    if [ ! -f /etc/passbolt/jwt/jwt.key ]; then
        echo "creating jwt keys ..."
        su -s /bin/bash -c "/usr/share/php/passbolt/bin/cake passbolt create_jwt_keys"
    fi
    chown -R root:www-data /etc/passbolt/jwt
    chmod 750 /etc/passbolt/jwt/
    [ -f /etc/passbolt/jwt/jwt.key ] && chmod 640 /etc/passbolt/jwt/jwt.key
    [ -f /etc/passbolt/jwt/jwt.pem ] && chmod 640 /etc/passbolt/jwt/jwt.pem

    echo "copied /jwt -> /etc/passbolt/jwt"
fi

chown www-data:www-data /etc/passbolt/gpg

#fix E-Mail Logo Path
sed -i "s@$fullBaseUrl \.@$fullBaseUrl . '$APP_BASE' . @g" /usr/share/php/passbolt/templates/layout/email/html/default.php
su -s /bin/bash -c "/usr/share/php/passbolt/bin/cake cache clear default" www-data
su -s /bin/bash -c "/usr/share/php/passbolt/bin/cake cache clear _cake_core_" www-data
su -s /bin/bash -c "/usr/share/php/passbolt/bin/cake cache clear _cake_model_" www-data

echo "Starting passbolt server ..."
. /docker-entrypoint.sh