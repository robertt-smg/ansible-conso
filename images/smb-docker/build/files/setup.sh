#!/bin/bash -x

echo "Updating image ..."
export TERM=linux
export TZ=Europe/Berlin

apk update
apk add --no-cache --update \
    samba-common-tools \
    samba-client \
    samba-server

rm -rf  /tmp/* /var/tmp/*  
mv /scripts/smb.conf /etc/samba/smb.conf


USERNAME="smb"
PASSWORD="Smb2025~free"
# Neuen Benutzer erstellen
adduser -D $USERNAME
# Passwort für den neuen Benutzer setzen
echo "$USERNAME:$PASSWORD" | chpasswd

addgroup smb bin

#SMB User smb
pdbedit -a -u smb

(echo "$PASSWORD"; echo "$PASSWORD") | smbpasswd -s -a $USERNAME


echo "Building version.txt ..."
echo "Build date: $(date)" > /version.txt

[ -f /etc/os-release ] && cat /etc/os-release >> /version.txt
[ -f /etc/lsb-release ] && cat /etc/lsb-release >> /version.txt
[ -f /etc/redhat-release ] && cat /etc/redhat-release >> /version.txt
echo Done ...
exit 0