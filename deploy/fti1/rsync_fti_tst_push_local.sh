#!/bin/bash
#!/bin/bash
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"
source $SCRIPTPATH/lib.sh $*

init

#rsync -avP -e "ssh -i /home/local_user/ssh/key_to_access_remote_server.pem" remote_user@remote_host.ip:/home/remote_user/file.gz /home/local_user/Downloads/
#rsync -avP -e "ssh" /mnt/d/Data/FTI/neocore ansible@fti1.app1.vm:/var/lib/percona/incoming/ 
rsync -avP -e "ssh" /mnt/d/Data/FTI/pciproxy ansible@fti1.app1.vm:/var/lib/percona/incoming/ 
