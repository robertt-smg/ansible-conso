#!/bin/bash

echo -e "\n ------------------------------------------------------------"
date
export MSYS_NO_PATHCONV=0
SCRIPT=`readlink -f -- $0`
SCRIPTPATH=$(cygpath -m $(dirname $SCRIPT))

if ! command -v podman &> /dev/null
then
    echo "Error: Podman is not installed. Please install Podman to continue."
    exit 1
fi
if ! podman machine list|grep podman-machine-default|grep -q running &> /dev/null
then
    podman machine start podman-machine-default
fi
if podman machine ssh date; then
    echo "ansible machine is running..."
else
    echo "Connection refused or another error occurred."
    echo "Try 'podman machine stop podman-machine-default && podman machine start podman-machine-default'"
    exit 1
fi
packages=("ansible" "openssh-clients" "podman-compose" "git" "pip" "sshpass")

for package in "${packages[@]}"; do
    if ! podman machine ssh "dnf list installed $package &> /dev/null"; then
        echo "Info: $package is not installed. Installing $package now ..."
        if ! podman machine ssh "dnf install -y $package"; then
            echo "Error: Failed to install $package."
            exit 1
        fi
    fi
done
pip_packages=("pywinrm")
for package in "${pip_packages[@]}"; do
    if ! podman machine ssh "pip show $package &> /dev/null"; then
        echo "Info: pip $package is not installed. Installing pip $package now ..."
        if ! podman machine ssh "pip install --user ansible $package"; then
            echo "Error: Failed to install $package."
            exit 1
        fi
    fi
done
echo "Connecting podman default root machine ..."
CONNECTION=$(podman system connection list|grep podman-machine-default-root)
URI=$(echo $CONNECTION|grep podman-machine-default-root|awk '{print $2}')
IDENT=$(echo $CONNECTION|grep podman-machine-default-root|awk '{print $3}')

user=$(echo "$URI" | sed 's|.*//\([^@]*\)@.*|\1|')
host=$(echo "$URI" | awk -F[@:] '{print $3}')
port=$(echo "$URI" | awk -F: '{print $3}' | awk -F/ '{print $1}')
PW=$(pwd)

cat <<EOF > /tmp/bashrc

echo "Welcome ..."
export PS1="\$(uname -s) \u@\h:\w \$ "
source ~/.bashrc

## we run in podman and share build dir from windows, so this is writeable 0777 and cannot be changed
export ANSIBLE_CONFIG=/mnt/$PW/ansible.cfg 

cd /mnt/$PW

EOF

scp -i $IDENT -P $port -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -o LogLevel=ERROR  /tmp/bashrc $user@$host:/tmp/bashrc
ssh -i $IDENT -p $port $user@$host -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -o LogLevel=ERROR -o SetEnv=LC_ALL= \
    -t  "/bin/bash --norc -c \"exec bash --init-file /tmp/bashrc  \""
