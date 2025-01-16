#!/bin/bash

WSL_CONF=$(cat <<EOF
[boot]
systemd=true
# remove NAT related ip configuration applied by WSL at boot
command = ip address flush dev eth0 # see networkctl command output for the interface name, assuming eth0 here
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
EOF
)
## second local network interface for port-forwarding gitlan.fti-group.com private address
ip addr add 127.83.20.1/16 dev lo

mkdir -p /etc/systemd/network
echo 'GatewayPorts clientspecified' >> /etc/ssh/sshd_config
echo '127.83.20.16    gitlab.fti-group.com' >> /etc/hosts
systemctl restart sshd

echo "$NETWORK_CONF" > /etc/systemd/network/10-eth0.network

systemctl enable systemd-networkd
systemctl restart systemd-networkd
systemctl status systemd-networkd
networkctl
systemctl enable systemd-resolved
systemctl start systemd-resolved
touch /etc/containers/nodocker

rm /mnt/wsl/resolv.conf && ln -sfv /run/systemd/resolve/resolv.conf /mnt/wsl/resolv.conf