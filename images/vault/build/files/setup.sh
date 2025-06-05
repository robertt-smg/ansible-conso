#!/bin/sh

echo "Updating image ..."
export TERM=linux
export TZ=Europe/Berlin

rm -rf  /tmp/* /var/tmp/*  
echo "Build date: $(date)" > /version.txt

apk update
echo "Saving version ..."

cat /etc/os-release

[ -f /etc/os-release ] && cat /etc/os-release >> /version.txt
[ -f /etc/lsb-release ] && cat /etc/lsb-release >> /version.txt
[ -f /etc/redhat-release ] && cat /etc/redhat-release >> /version.txt

echo Update done ...