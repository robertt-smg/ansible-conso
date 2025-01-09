#!/bin/bash

echo "Updating image ..."
export TERM=linux
export TZ=Europe/Berlin
export DEBIAN_FRONTEND=noninteractive

apt-get update
echo "Installing packages..."

apt-get -y install --no-install-recommends apt-utils
apt-get -y install inetutils-ping rsyslog iproute2 socat git curl unzip make

echo Creating directories ...
mkdir -p /etc/rsyslog.d/
mkdir -p /usr/local/etc/haproxy
mkdir -p /var/log/rsyslogd
mkdir -p /usr/local/http
mkdir -p /var/log/haproxy

mkdir -p /run/rsyslogd
chown haproxy:haproxy /run/rsyslogd

chmod ag+rw /var/log/haproxy
chmod ag+rw /var/log/rsyslogd

echo "Installing lua AUTH ..."
pushd /tmp
git clone https://github.com/haproxytech/haproxy-lua-oauth.git
cd haproxy-lua-oauth
bash ./install.sh luaoauth

echo "Cleaning image ..."
apt-get -y purge make
apt-get clean
apt-get autoremove -y
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*  


echo "Build date: $(date)" > /version.txt


[ -f /etc/os-release ] && cat /etc/os-release >> /version.txt
[ -f /etc/lsb-release ] && cat /etc/lsb-release >> /version.txt
[ -f /etc/redhat-release ] && cat /etc/redhat-release >> /version.txt
haproxy -v >> /version.txt