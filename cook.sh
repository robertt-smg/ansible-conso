#!/bin/bash
#set -x
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"
LIBPATH="$SCRIPTPATH/lib"

source $LIBPATH/common.sh

IV="${SCRIPTPATH}/inventories"
export ANSIBLE_CONFIG=$SCRIPTPATH/ansible.cfg

# Define the trap function
ctrl_c() {
    echo
    echo "** Trapped CTRL-C"
    # Add any cleanup code here
    exit 1
}
# Set up the trap
trap ctrl_c INT

# Usage function
usage() {
    echo "Usage: $0 [option]"
    echo "Options:"
    echo "  -c, --connect                Connect to ansible build VM"
    
    echo "  -r, --install-roles          Install ansible galaxy roles from requirements.txt"
    echo "  -b, -t, --build, --build-tst Build servers in test [ansible-playbook options e.g. --limit server1]"
    echo "  -p, --build-prd              Build servers in prod [ansible-playbook options e.g. --limit server1]"
    echo "  <-b | -p > --dump_vars       Dump variables in test [ansible-playbook options e.g. --limit server1]"
    echo "  <-b | -p > --dump_groups     Dump groups in test [ansible-playbook options e.g. --limit server1]"
    echo "  <-b | -p > --play <play>     Build differen playbook [ansible-playbook options e.g. --limit server1]"
    echo "  -w, --win-tst [ --bootstrap] Build Windows servers in test [ansible-playbook options e.g. --limit server1]"
    echo "  -m, --win-prd [ --bootstrap] Build Windows servers in prod [ansible-playbook options e.g. --limit server1]"
    echo "  <-b/-p/-w/-m > --inventory   List inventory"
    echo "  -v, --start-vm               Start virtual machine <server>"
    echo "  -h, --help                   Display this help message"
}

# Install galaxy roles
install_roles() {
    echo ${FUNCNAME[0]}
    
    ansible-galaxy install -r ${SCRIPTPATH}/requirements.yml --roles-path ${SCRIPTPATH}/roles.external $*
    ansible-galaxy collection install -r ${SCRIPTPATH}/requirements-collections.yml --collections-path ${SCRIPTPATH}/collections.external $*
}
function check_opts_and_run() {
    echo ${FUNCNAME[0]} $*

    if [ "$1" = "--bootstrap-play" ]; then
        BOOTSTRAP_PLAY=${1}
        shift
    fi
    if [ "$1" = "--dump_vars" ]; then
        DEFAULT_PLAY=dump_vars.yml
        DEFAULT_BOOTSTRAP_PLAY=dump_vars.yml
        shift
    fi
    if [ "$1" = "--dump_groups" ]; then
        DEFAULT_PLAY=dump_groups.yml
        DEFAULT_BOOTSTRAP_PLAY=dump_groups.yml
        shift
    fi
    if [ "$1" = "--play" ]; then
        shift
        DEFAULT_PLAY=$1
        shift
    fi
    if [ "$1" = "--bootstrap" ]; then
        INVENTORY="-i ${IV}/${INVENTORY}-bootstrap -i ${IV}/${IVGROUPS} "
        BOOTSTRAP_PLAY=${DEFAULT_BOOTSTRAP_PLAY:-bootstrap_linux.yml}
        shift
    else
        INVENTORY="-i ${IV}/${INVENTORY} -i ${IV}/${IVGROUPS} "
    fi
    if [ "$1" = "--inventory" ]; then
        ANSIBLE_CMD="ansible-inventory"
        EXTRA_OPS=" --list --yaml"
        shift
    else
        ANSIBLE_CMD="ansible-playbook"
    fi
    if [ ! -z "$BOOTSTRAP_PLAY" ]; then
        logfile=install-bootstrap-$(date +%Y-%m-%d-%H-%M-%S).log
        set -x
        ${ANSIBLE_CMD} ${INVENTORY} ${SCRIPTPATH}/plays/${BOOTSTRAP_PLAY} ${EXTRA_OPS} $* |& tee $logfile
        if [ $? -ne 0 ]; then
          echo "Ansible playbook ${BOOTSTRAP_PLAY} execution failed. Exiting."
          exit 1
        fi
        echo "Ansible playbook ${BOOTSTRAP_PLAY} execution completed. $logfile"
    else
        logfile=install-$(date +%Y-%m-%d-%H-%M-%S).log
        set -x
        ${ANSIBLE_CMD} ${INVENTORY} ${EXTRA_OPS} $* ${SCRIPTPATH}/plays/${DEFAULT_PLAY} |& tee $logfile
        if [ $? -ne 0 ]; then
            echo "Ansible playbook ${DEFAULT_PLAY} execution failed. Exiting."
            exit 1
        fi
        echo "Ansible playbook ${DEFAULT_PLAY} execution completed. $logfile"
    fi
}
# Build a server/s
build_on_test() {
    echo ${FUNCNAME[0]}
    is_linux

    DEFAULT_PLAY="install-linux.yml"
    IVGROUPS=groups
    
    check_ssh_agent

    INVENTORY="lnx-tst"
    check_opts_and_run $*
}
# Build a server/s
build_on_win_test() {
    echo ${FUNCNAME[0]}
    is_linux

    DEFAULT_PLAY="install-windows.yml"
    DEFAULT_BOOTSTRAP_PLAY="bootstrap_win.yml"
    IVGROUPS="groups-win"
    check_ssh_agent

    INVENTORY="win-tst"
    check_opts_and_run $*
}
build_on_win_prod() {
    echo ${FUNCNAME[0]}
    is_linux

    DEFAULT_PLAY="install-windows.yml"
    DEFAULT_BOOTSTRAP_PLAY="bootstrap_win.yml"
    IVGROUPS="groups-win"
    check_ssh_agent

    INVENTORY="win-prd"
    check_opts_and_run $*
}
build_on_prod() {
    echo ${FUNCNAME[0]}
    is_linux

    DEFAULT_PLAY="install-linux.yml"
    IVGROUPS=groups
    check_ssh_agent

    INVENTORY="prd"
    check_opts_and_run $*
}

function start_vm() {
    echo ${FUNCNAME[0]}

    if [ -d $SCRIPTPATH/la-cuna-icu.vm/$1 ]; then
        bash $SCRIPTPATH/la-cuna-icu.vm/$1/up.sh
    else
        echo "VM for server $1 not found ($SCRIPTPATH/la-cuna-icu.vm/$1) ..."
    fi
}
# Main script logic
if [ "$#" -eq 0 ]; then
    usage
    exit 1
fi
opt="$1"
shift

case "$opt" in
    -c|--connect)
        connect_builder
        ;;
    -r|--install-roles)
        install_roles $*
        ;;
    -t|-b|--build|--build-tst)
        build_on_test $*
        ;;
    -p|--build-prd)
        build_on_prod $*
        ;;
    -w|-b|--win-tst)
        build_on_win_test $*
        ;;
    -m|--win-prd)
        build_on_win_prod $*
        ;;
    -v|--start-vm)
        start_vm $*
        ;;
    -h|--help)
        usage
        ;;
    *)
        echo "Invalid option"
        usage
        exit 1
        ;;
esac