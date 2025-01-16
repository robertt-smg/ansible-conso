#!/bin/bash

echo Alive $PID ....
#!/bin/bash

mkdir -p /root/.ssh

ssh_auth_sock=$(cat <<EOF
Defaults    env_keep+=SSH_AUTH_SOCK
EOF
)
echo "${ssh_auth_sock}" | sudo tee --append /etc/sudoers.d/ssh_auth_sock

# Fake gitlab.fti-group.com Server network / forwared by ssh -R ...
ip addr add 127.83.20.1/16 dev lo

echo System running ...
echo " you can bootstrap this server with: wget https://thr27.github.io/la-cuna-icu-bootstrap/b.sh && bash b.sh"
exec /usr/sbin/init 2
