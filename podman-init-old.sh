#!/bin/bash
if [ "$1" == "PRE" ]; then
    WSL_CONF=$(cat <<EOF
    [boot]
    systemd=true
    # remove NAT related ip configuration applied by WSL at boot
    command = ip address flush dev eth0 && dhclient eth0 # see networkctl command output for the interface name, assuming eth0 here
    [network]
    generateResolvConf = false
EOF
    )

    echo "$WSL_CONF" |tee /etc/wsl.conf
    #systemctl stop NetworkManager
    #systemctl disable NetworkManager

    NETWORK_CONF=$(cat <<EOF
    [Match]
    Name=eth0
    [Network]
    DHCP=yes
    DNS=8.8.8.8
    DNS=8.8.4.4
EOF
    )
    ## second local network interface for port-forwarding gitlan.fti-group.com private address
    ip addr add 127.83.20.1/16 dev lo

    mkdir -p /etc/systemd/network
    echo 'GatewayPorts clientspecified' >> /etc/ssh/sshd_config
    echo '127.83.20.16    gitlab.fti-group.com' >> /etc/hosts
    systemctl restart sshd

    echo "$NETWORK_CONF" > /etc/systemd/network/10-eth0.network
fi

if [ "$1" == "POST" ]; then
    # Ensure proper DNS resolution setup
    rm -f /etc/resolv.conf
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

    # Set correct permissions
    mkdir -p /run/systemd/resolve/
    chown -R systemd-resolve:systemd-resolve /run/systemd/resolve/
    systemctl daemon-reload

    systemctl enable systemd-networkd
    systemctl restart systemd-networkd
    systemctl status systemd-networkd
    networkctl

    systemctl enable systemd-resolved
    systemctl restart systemd-resolved
    systemctl status systemd-resolved

    touch /etc/containers/nodocker

    rm -f /mnt/wsl/resolv.conf && ln -sfv /run/systemd/resolve/resolv.conf /mnt/wsl/resolv.conf
fi