#!/bin/bash
if [ "$1" == "PRE" ]; then
    WSL_CONF=$(cat <<EOF
    [boot]
    systemd=true
    # remove NAT related ip configuration applied by WSL at boot
    command = "ip address flush dev eth0 && dhclient eth0" # see networkctl command output for the interface name, assuming eth0 here
    [network]
    generateResolvConf = false
EOF
    )

    echo "$WSL_CONF" |tee /etc/wsl.conf

    ## second local network interface for port-forwarding gitlan.fti-group.com private address
    ip addr add 127.83.20.1/16 dev lo

    echo 'GatewayPorts clientspecified' >> /etc/ssh/sshd_config
    echo '127.83.20.16    gitlab.fti-group.com' >> /etc/hosts
    systemctl restart sshd
fi

if [ "$1" == "POST" ]; then
    # Ensure proper DNS resolution setup
    touch /etc/containers/nodocker
    rm -f /etc/resolv.conf
    RESOLV_CONF=$(cat <<EOF
nameserver 192.168.178.1
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
    )

    echo "$RESOLV_CONF" > /etc/resolv.conf
fi