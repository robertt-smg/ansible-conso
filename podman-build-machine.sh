#!/bin/bash

if podman machine list | grep -q podman-machine-default; then
    podman machine stop podman-machine-default
    podman machine rm podman-machine-default
fi

podman machine init --cpus=4 --memory=8192
podman machine set --rootful
podman machine start

## based on https://github.com/colemar/Win10WSL2UbuntuExternalIP?tab=readme-ov-file
## make sure Hyper-V Switch WSL is connected to real network

WSL_CONF=$(cat <<EOF
[boot]
systemd=true
# remove NAT related ip configuration applied by WSL at boot
command = ip address flush dev eth0 # see networkctl command output for the interface name, assuming eth0 here
[network]
generateResolvConf = false
EOF
)

echo "$WSL_CONF" | podman machine ssh "tee /etc/wsl.conf"
podman machine ssh "systemctl stop NetworkManager; systemctl disable NetworkManager"
NETWORK_CONF=$(cat <<EOF
[Match]
Name=eth0
[Network]
DHCP=yes
EOF
)
podman machine ssh "mkdir /etc/systemd/network"
echo "$NETWORK_CONF" | podman machine ssh "cat > /etc/systemd/network/10-eth0.network"

podman machine ssh "systemctl enable systemd-networkd"
podman machine ssh "systemctl restart systemd-networkd"
podman machine ssh "systemctl status systemd-networkd"
podman machine ssh "networkctl"
podman machine ssh "systemctl enable systemd-resolved"
podman machine ssh "systemctl start systemd-resolved"

podman machine ssh "rm /mnt/wsl/resolv.conf && ln -sfv /run/systemd/resolve/resolv.conf /mnt/wsl/resolv.conf"