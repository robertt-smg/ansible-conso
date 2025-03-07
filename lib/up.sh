#!/bin/bash
echo -e "\n ------------------------------------------------------------"
echo $0
date

LIBPATH="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
export ROOTPATH="$(realpath "$LIBPATH/..")"
source $LIBPATH/common.sh
source ${LIBPATH}/token.secrets

SOURCE_AS_LIB=1
SOURCE_CERT_DIR="${LIBPATH}/../../ssl/cert/archive"
CERT_DIR="${LIBPATH}/../../ssl/cert/current"

function podman_login() {
    echo ${FUNCNAME[0]}
    
    # podman login registry.gitlab.com -u "${GLCR_USER}" -p "${GLCR_TOKEN}"
	podman login ${GITHUB_REGISTRY} -u "${GITHUB_USER}" -p "${GITHUB_TOKEN}"
}
function copy_certs() {
	echo ${FUNCNAME[0]}

# Loop through each subdirectory in the source directory
	find "$SOURCE_CERT_DIR" -type d | while read -r dir; do
		# Find the youngest cert file
		find "$dir" -maxdepth 1 -type f -name "*.pem" -printf '%T@ %p\n' | sort -n | cut -d' ' -f2| while read -r youngest_file; do

			# If a youngest file is found
			if [ -n "$youngest_file" ]; then
				# Get the base directory name without the number
				base_dir=$(basename "$dir")
				new_dir="${CERT_DIR}/${base_dir}"
				
				filename=$(basename $youngest_file)
				new_file="${new_dir}/${filename//[0-9]/}"  # Remove numbers from the directory name

				# Create the destination directory if it doesn't exist
				mkdir -p "$new_dir"

				# Copy the youngest file to the new directory and rename it
				cp "$youngest_file" "$new_file"
			fi
		done
	done

	export CERT_DIR
}
function copy_ssh() {
	SSH_DIR=/tmp/ssh
	mkdir -p $SSH_DIR

	cp ~/.ssh/id_* $SSH_DIR
	cp ~/.ssh/authorized_keys.add $SSH_DIR
}
function start_container() {
	echo ${FUNCNAME[0]}

	is_linux

	podman_login

	export PODMAN_IGNORE_CGROUPSV1_WARNING=1
	export PODMAN_COMPOSE_WARNING_LOGS=1

	if ! podman network ls|grep -q salt-vm; 
	then  
		echo creating network salt-vm; 
		podman network create -d bridge --subnet=192.168.11.0/24 salt-vm
	fi
	cat > ${SCRIPTPATH}/.env <<EOF
	GITHUB_REGISTRY=${GITHUB_REGISTRY}
	GITHUB_OWNER=${GITHUB_OWNER}
	${EXTRA_ENV}
EOF
	PROJECT_NAME=$(basename $(pwd))-$(basename $(dirname $(pwd)))
	if [ $rebuild -eq 1 ]; then
		podman-compose -p $PROJECT_NAME -f ${SCRIPTPATH}/docker-compose.yml down --remove-orphans
		podman-compose -p $PROJECT_NAME -f ${SCRIPTPATH}/docker-compose.yml build 
		podman-compose -p $PROJECT_NAME -f ${SCRIPTPATH}/docker-compose.yml up --remove-orphans --force-recreate 
	else
		podman-compose -p $PROJECT_NAME -f ${SCRIPTPATH}/docker-compose.yml down
		podman-compose --podman-args="--log-level debug" -p $PROJECT_NAME -f ${SCRIPTPATH}/docker-compose.yml up
	fi
}
 
function up() {
	echo ${FUNCNAME[0]}

	is_linux
	copy_certs
	start_container
}
function hyper_v_build() {
	echo ${FUNCNAME[0]}

	if [ ! -f ${HYPER_V_BUILD_PATH}/New-HyperVCloudImageVM.ps1 ]; then
		echo "Error: please clone github.com:robertt-smg/hyperv-vm-provisioning.git into  ${HYPER_V_BUILD_PATH}"
	else
		echo "Creating Hyper-V Linux VM $VMName ..."
		# Run PowerShell command to create Ubuntu VM
		powershell.exe -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; \
			& \"$(cygpath -w $HYPER_V_BUILD_PATH)/New-HyperVCloudImageVM.ps1\" \
			-VMProcessorCount 8 \
			-VMMemoryStartupBytes 8GB \
			-VHDSizeBytes 60GB \
			-VMName \"${VMName}\" \
			-ImageVersion \"${VMImageVersion}\" \
			-VMGeneration 2 \
			-ShowSerialConsoleWindow \
			-KeyboardLayout de \
			-ShowVmConnectWindow \
			-GuestAdminPassword \"${VMPassword}\" \
			-GuestAdminUsername \"admin\" \
			-virtualSwitchName \"VM Bridge\" \
			-VMStaticMacAddress \"${VMMacAddress}\" \
			-NetConfigType \"v2\" \
			-NetNetmask \"255.255.255.0\" \
			-NetAddress \"${VMIpAddress}/24\" \
			-NetGateway \"192.168.121.2\" \
			-NameServers \"192.168.121.2,1.1.1.1,4.4.4.4\" \
			-DomainName \"smg-conso.vm\" \
			-VMMachine_StoragePath \"\$env:ProgramData\hyperv-vm-provisioning\""
	fi
}
function usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -u, --up             Start VM"
    echo "  -c, --connect        Connect to the builder VM"
    echo "  -r, --rebuild        Restart a clean VM, destroy old VM"
    echo "  -h, --help       Show this help message"
}
rebuild=0
# Option parsing
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -u|--up)        up;;
        -c|--connect)      connect_builder; exit 0 ;;
        -r|--rebuild)      rebuild=1 ;;
        -h|--help)      usage; exit 0 ;;
        *) up; exit 1 ;;
    esac
    shift
done