#!/bin/bash

echo "Updating image ..."
export TERM=linux
export TZ=Europe/Berlin

rm -rf  /tmp/* /var/tmp/*  
echo "Build date: $(date)" > /version.txt

mkdir -p /var/log/lighttpd
chown 1001:1000 /var/log/lighttpd

apt-get update
apt-get install -y lighttpd

[ -f /etc/os-release ] && cat /etc/os-release >> /version.txt
[ -f /etc/lsb-release ] && cat /etc/lsb-release >> /version.txt
[ -f /etc/redhat-release ] && cat /etc/redhat-release >> /version.txt
lighttpd -v >> /version.txt
mysqld --version >> /version.txt