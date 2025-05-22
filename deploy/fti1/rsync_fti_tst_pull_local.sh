#!/bin/bash
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"
source $SCRIPTPATH/lib.sh $*

init

#rsync -avP -e "ssh -i /home/local_user/ssh/key_to_access_remote_server.pem" remote_user@remote_host.ip:/home/remote_user/file.gz /home/local_user/Downloads/
#rsync -avP -e "ssh" root@aqdb1.prd.muc01.fti.int:/mnt/netapp_aqdb1_db/aqdb1/mysql/neocore  /mnt/d/Data/FTI/
rsync -avP -e "ssh" root@aqdb1.prd.muc01.fti.int:/mnt/netapp_aqdb1_db/aqdb1/mysql/pciproxy  /mnt/d/Data/FTI/
