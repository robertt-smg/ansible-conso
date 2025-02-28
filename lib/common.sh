#!/bin/bash
#set -x

LIBPATH="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
HYPER_V_BUILD_PATH="$(realpath $LIBPATH/../../hyper-v/hyperv-vm-provisioning/)"

function is_linux() {
    echo ${FUNCNAME[0]}
    if [ "$(uname)" != "Linux" ]; then
        echo "This script only runs on Linux. Exiting."
        echo "use $0 --connect, first"
        exit 1
    fi
}
function is_windows() {
    echo ${FUNCNAME[0]}
    if [ "$(uname)" == "Linux" ]; then
        echo "This script only runs on Windows. Exiting."
        exit 1
    fi
}
function connect_builder() {
    echo ${FUNCNAME[0]}

    check_ssh_agent

    . $LIBPATH/../podman-vm-connect.sh
}
function check_ssh_agent() {
    echo ${FUNCNAME[0]}
    
    # Check if we have SSH_AUTH_SOCK (indicates agent forwarding or local agent)
    if [ -z "$SSH_AUTH_SOCK" ]; then
        echo "No SSH agent detected. Starting new ssh-agent..."
        eval $(ssh-agent)
    fi
    pwd
    # Try to list keys and capture both output and exit status
    ssh_output=$(ssh-add -L 2>&1)
    ssh_status=$?

    # Check for specific error conditions
    if [ $ssh_status -eq 2 ]; then
        if [ -n "$SSH_AUTH_SOCK" ] && [ -n "$SSH_CONNECTION" ]; then
            echo "Error: Could not connect to forwarded ssh-agent. Check if agent forwarding is enabled in your SSH config."
            return 1
        else
            echo "Could not connect to ssh-agent. Starting new agent..."
            eval $(ssh-agent)
            ssh_output=$(ssh-add -L 2>&1)
            ssh_status=$?
        fi
    fi

    # Count keys if ssh-add succeeded
    if [ $ssh_status -eq 0 ]; then
        count=$(echo "$ssh_output" | wc -l)
        if [ "$count" -lt 1 ]; then
            echo "Alert: No SSH keys found. You may need to add keys using: ssh-add ~/.ssh/id_rsa"
            echo "If using agent forwarding, ensure keys are added on the client machine."
        elif [ "$count" -gt 6 ]; then
            echo "Warning: Too many SSH keys found ($count > 6). Your host may decline connect as of too many wrong keys if key is at the end of the list ..."
        fi
    else
        echo "Error: Failed to list SSH keys. Error message: $ssh_output"
        exit 1
    fi
}
function win_sudo_me() {
    echo ${FUNCNAME[0]}
    if ! net session  >/dev/null 2>&1
    then
        echo "Script must be run elevated!"
        sudo -E --inline bash $*
    else
        run
    fi
}
