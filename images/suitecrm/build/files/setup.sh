#!/bin/bash -x

echo "Updating image ..."
export TERM=linux
export TZ=Europe/Berlin

rm -rf  /tmp/* /var/tmp/*  
echo "Building version.txt ..."
echo "Build date: $(date)" > /version.txt

apt install php_imap

[ -f /etc/os-release ] && cat /etc/os-release >> /version.txt
[ -f /etc/lsb-release ] && cat /etc/lsb-release >> /version.txt
[ -f /etc/redhat-release ] && cat /etc/redhat-release >> /version.txt
echo Done ...
exit 0