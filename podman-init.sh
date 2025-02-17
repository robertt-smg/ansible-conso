#!/bin/bash
if [ "$1" == "PRE" ]; then

    echo 'GatewayPorts clientspecified' >> /etc/ssh/sshd_config
    echo '127.83.20.16    gitlab.fti-group.com' >> /etc/hosts
    systemctl restart sshd
fi

if [ "$1" == "POST" ]; then
#    # Ensure proper DNS resolution setup
#    touch /etc/containers/nodocker
#    rm -f /etc/resolv.conf
#    RESOLV_CONF=$(cat <<EOF
#nameserver 192.168.178.1
#nameserver 8.8.8.8
#nameserver 8.8.4.4
#EOF
#   )

#    echo "$RESOLV_CONF" > /etc/resolv.conf
    echo done
fi