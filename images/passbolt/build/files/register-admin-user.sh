#!/bin/bash

su -m -c "/usr/share/php/passbolt/bin/cake passbolt register_user \
    -u ${EMAIL_ADMIN_USER} \
    -f ${EMAIL_ADMIN_NAME} \
    -l ${EMAIL_ADMIN_LASTNAME} \
    -r admin" -s /bin/sh www-data