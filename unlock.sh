#!/bin/bash
SCRIPT=`readlink -f -- $0`
SCRIPTPATH=`dirname $SCRIPT`
PROJECT_NAME=$(basename ${SCRIPTPATH})
KEY_FILE=${SCRIPTPATH}/../${PROJECT_NAME}-unlock.key
SSH_AGENT_COMMENT=${PROJECT_NAME}

function load_secret_key_from_ssh_agent() {
	echo ${FUNCNAME[0]}

	if ! type "ssh-add" &> /dev/null; then
		echo ERROR: ssh-add not installed
		return 1
	fi
	
	if ! set |grep -q SSH_AUTH_SOCK 2>/dev/null; then
		echo ERROR: cannot connect to ssh-agent - is ssh_agent_forwarding active?
		echo Please enable ssh-agent-forwarding and add ssh key with Key comment ${SSH_AGENT_COMMENT} ..
		echo We use ssh-agent to retrieve git-crypt key
		return 1
	else
		GIT_CRYPT_KEY=$(ssh-add -L |grep ${SSH_AGENT_COMMENT}|awk '{ print $4 }')

		if [ $? -ne 0 ]; then
			echo Cannot get key for "$SSH_AGENT_COMMENT", please setup key in ssh-agent/keepass with $SSH_AGENT_COMMENT as comment on key
			echo Use git-crypt export-key key.txt && cat key.txt |xxd -ps -c 4096, and add to a ssh-key as comment
            echo "Add to a ssh-key Keyfile as 'Key comment: $SSH_AGENT_COMMENT <hex dump of exported git-crypt key>'"
			
			return 1
		else
			echo ${GIT_CRYPT_KEY} | xxd -r -p > ${KEY_FILE}
		fi
	fi
	return 0
}


function unlock_git() {
	echo ${FUNCNAME[0]}

	if [ ! -f $KEY_FILE ] ; then
		echo "Download decrypt key for secret files ..."
		load_secret_key_from_ssh_agent ${PROJECT_NAME}
		if [ $? -ne 0 ]; then
			echo ERROR load_secret_key_from_keepass failed ...
			echo Please check your ssh-agent settings
			return 1
		fi
	fi

	if [ -f $KEY_FILE ]; then
		git-crypt unlock $KEY_FILE
		if [ $? -ne 0 ]; then
			echo ERROR git-unlock failed ...
			return 1
		fi
	fi

	return 0
}
function is_unlocked() {
	echo ${FUNCNAME[0]}

	if grep -q "decryption OK" $SCRIPTPATH/unlock.key 
	then
		echo "Ok, Project is unlocked ..."
		return 0
	else
		return 1
	fi
}
if ! is_unlocked; then
    unlock_git
    if [ $? -ne 0 ]; then
        echo ERROR unlock_git failed ...
        return 1
    fi
fi
