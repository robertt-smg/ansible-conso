#!/bin/bash
#set -x
export PODMAN_IGNORE_CGROUPSV1_WARNING=1
LIBPATH="$(dirname "${BASH_SOURCE[0]}")"

source $LIBPATH/common.sh

if [ "$#" -eq 0 ]; then
    set -- --build  # Set default argument
fi
[ -z "$SCRIPTPATH" ] && SCRIPTPATH=$(pwd)

function is_linux() {
    echo ${FUNCNAME[0]}
    if [ "$(uname)" != "Linux" ]; then
        echo "This script only runs on Linux. Exiting."
        echo "use $0 --connect, first"
        exit 1
    fi
}
function install_in_ubuntu() {
    echo ${FUNCNAME[0]}
    apt update &&\
        apt install -y software-properties-common &&\
        add-apt-repository --yes --update ppa:ansible/ansible &&\
        apt install -y python3-passlib python3-pexpect ansible    
}
function install_in_centos() {
    echo ${FUNCNAME[0]}

    packages=("ansible" "openssh-clients" "podman-compose" "git")

    for package in "${packages[@]}"; do
        if ! dnf list installed $package &> /dev/null; then
            echo "Info: $package is not installed. Installing $package now ..."
            if ! dnf install -y $package; then
                echo "Error: Failed to install $package."
                exit 1
            fi
        fi
    done
}
function install_in_debian() {
    echo ${FUNCNAME[0]}
    case "$VERSION_ID" in 
        "12") ## Debian 12 (Bookworm)
            UBUNTU_CODENAME="jammy"
        ;;
        "11") ## Debian 11 (Bullseye)
            UBUNTU_CODENAME="focal"
        ;;
        "10" ) ## Debian 10 (Buster)
            UBUNTU_CODENAME="bionic"
        ;;
        *)
            UBUNTU_CODENAME="unknown"
            exit -1
        ;;
    esac
    apt update
    apt install -y software-properties-common wget gpg
    wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | tee /etc/apt/sources.list.d/ansible.list
    apt update && apt install -y python3-passlib python3-pexpect ansible
}
function install_ansible() {
    echo ${FUNCNAME[0]}
    [ -f /etc/os-release ] && source /etc/os-release
    [ -f /etc/lsb-release ] && source /etc/lsb-release
    [ -f /etc/redhat-release ] && ID=centos

    case "$ID" in 
        ubuntu)
           install_in_ubuntu
            ;;
        debian)
            install_in_debian
            ;;
        centos)
            install_in_centos
            ;;
        *)
        echo "Unknown OS: $ID $VERSION_ID - cannot install ansible"
        exit -1
        ;;
    esac
}
function purge_ansible_ubuntu() {
    echo ${FUNCNAME[0]}
    
    apt-get purge -y ansible ansible-core
    dpkg -l | grep python | awk '{print $2}' | xargs apt-get purge -y
    rm -rf /etc/ansible
    rm -rf ~/.ansible
    apt-get autoremove -y
}
function purge_ansible_centos() {
    echo ${FUNCNAME[0]}
    yum remove -y python3-passlib python3-pexpect ansible ansible-core
    
    rpm -qa | grep python | xargs yum remove -y
    rm -rf /etc/ansible
    rm -rf ~/.ansible
    yum autoremove -y
}
function purge_ansible() {
    echo ${FUNCNAME[0]}
     ## we remove ansible as this is used to test install on bare VMs
    [ -f /etc/os-release ] && source /etc/os-release
    [ -f /etc/lsb-release ] && source /etc/lsb-release
    [ -f /etc/redhat-release ] && ID=centos

    case "$ID" in 
        ubuntu)
            purge_ansible_ubuntu
            ;;
        debian)
            purge_ansible_ubuntu
            ;;
        centos)
            purge_ansible_centos
            ;;
        *)
        echo "Unknown OS: $ID $VERSION_ID - cannot purge ansible"
        exit -1
        ;;
    esac
    [ -d /etc/ansible ] && rm -rf /etc/ansible
    [ -d ~/.ansible ] && rm -rf ~/.ansible
}
# this runs inside podman container
function run_ansible_in_container() {
    echo ${FUNCNAME[0]}

    if ! command -v ansible-playbook >/dev/null 2>&1; then
        install_ansible
    fi
    ansible --version

    mkdir -p /etc/ansible
    cp ${SCRIPTPATH}/.ansible.cfg /etc/ansible/ansible.cfg
    cp ${SCRIPTPATH}/*.yml /etc/ansible/
    [ -f /etc/ansible/requirements.yml ] && ansible-galaxy install -r /etc/ansible/requirements.yml
    ansible-playbook /etc/ansible/playbook.yml --connection=local -v -e "BASEDIR=${SCRIPTPATH}"

    if declare -f "cleanup" > /dev/null; then
        cleanup
    fi
    
}
function set_vars() {
    
    echo ${FUNCNAME[0]}
    DOCKERFILE=${DOCKERFILE:-Dockerfile}

    if [ -f ${SCRIPTPATH}/${DOCKERFILE} ]; then
        BUILD_IMAGE=$(grep -E -e "^FROM " ${SCRIPTPATH}/${DOCKERFILE} |grep -v '#'|awk '{ print $2 }')
        AUTHOR="$(grep -E -e "^LABEL maintainer=" ${SCRIPTPATH}/${DOCKERFILE} |grep -v '#'|sed 's/LABEL maintainer=//g')"
        CMD="$(grep -E -e "^CMD " ${SCRIPTPATH}/${DOCKERFILE} |grep -v '#'|awk '{ for (i=2; i<=NF; i++) printf "%s%s", $i, (i<NF ? OFS : ""); print "" }')"
        ENTRYPOINT="$(grep -E -e "^ENTRYPOINT " ${SCRIPTPATH}/${DOCKERFILE} |grep -v '#'|awk '{ for (i=2; i<=NF; i++) printf "%s%s", $i, (i<NF ? OFS : ""); print "" }')"
    fi
    IMAGE_NAME=${IMAGE_NAME:-$(basename $(realpath ${SCRIPTPATH}/..))}
    IMAGE_TAG=${IMAGE_TAG:-latest}
}
function run_build() {
    echo ${FUNCNAME[0]}

    is_linux    
    logfile=build-$(date +%Y-%m-%d-%H-%M-%S).log
    if [ -f ${SCRIPTPATH}/playbook.yml ]; then

        podman run -it -e TZ=Europe/Berlin -e DEBIAN_FRONTEND=noninteractive -v ${SCRIPTPATH}/../../..:${SCRIPTPATH}/../../..:ro \
            --user root \
            --replace --name ansible-build-${IMAGE_NAME} ${BUILD_IMAGE} /bin/bash -c "${SCRIPTPATH}/build.sh --run-ansible" |& tee $logfile
    else
        podman build  --format docker --tag ${IMAGE_NAME}:${IMAGE_TAG} -f ${SCRIPTPATH}/${DOCKERFILE} |& tee $logfile
    fi
}
function run_terminal() {
    echo ${FUNCNAME[0]}
    podman run -it -e TZ=Europe/Berlin -e DEBIAN_FRONTEND=noninteractive -v ${SCRIPTPATH}/../../..:${SCRIPTPATH}/../../..:ro \
        --user root \
        --replace --name ansible-build-${IMAGE_NAME} ${BUILD_IMAGE} /bin/bash
}
function export_image() {
    echo ${FUNCNAME[0]}

    is_linux
    if [ -f ${SCRIPTPATH}/playbook.yml ]; then
        echo "Exporting image ${IMAGE_NAME}:${IMAGE_TAG} from container ansible-build-${IMAGE_NAME} ..."
        podman container commit -s ansible-build-${IMAGE_NAME} ${IMAGE_NAME}:${IMAGE_TAG} -c=CMD="${CMD}" -c=ENTRYPOINT="${ENTRYPOINT}"
    else
        if podman image exists ${IMAGE_NAME}:${IMAGE_TAG}; then
            echo "Image ${IMAGE_NAME}:${IMAGE_TAG} was built with 'podman build' - no export needed"
        else
            echo "Image ${IMAGE_NAME}:${IMAGE_TAG} not found ... please build image"
        fi
    fi
}
function podman_login() {
    echo ${FUNCNAME[0]}
    source ${LIBPATH}/token.secrets
    #podman login registry.gitlab.com -u "${GLCR_USER}" -p "${GLCR_TOKEN}"
    podman login ${GITHUB_REGISTRY} -u "${GITHUB_USER}" -p "${GITHUB_TOKEN}"
}
function podman_upload() {
	echo ${FUNCNAME[0]} $*
	
	LOCAL=${1}
	IMAGE=${2/:/_}
	TAG=${3:-latest}
	
	echo Pushing to registry ${GITHUB_REGISTRY}/${GITHUB_OWNER} ...
    if podman image exists ${IMAGE}:${LOCAL}; then

        #podman tag ${IMAGE}:${LOCAL} registry.gitlab.com/la-cuna-icu/podman-images/${IMAGE}:${TAG}
        #podman push registry.gitlab.com/la-cuna-icu/podman-images/${IMAGE}:${TAG}
        #podman tag registry.gitlab.com/la-cuna-icu/podman-images/${IMAGE}:${TAG} ${IMAGE}:${LOCAL}
        podman tag ${IMAGE}:${LOCAL} ${GITHUB_REGISTRY}/${GITHUB_OWNER}/${IMAGE}:${TAG}
        podman push ${GITHUB_REGISTRY}/${GITHUB_OWNER}/${IMAGE}:${TAG}
        podman tag ${GITHUB_REGISTRY}/${GITHUB_OWNER}/${IMAGE}:${TAG} ${IMAGE}:${LOCAL}

        echo "New Image name: ${GITHUB_REGISTRY}/${GITHUB_OWNER}/${IMAGE}:${TAG}"
    else
        echo "Image ${IMAGE_NAME}:${LOCAL} not found ... please build image"
    fi
}
function push_image() {
    echo ${FUNCNAME[0]} $*

    if [[ -f "$SCRIPTPATH/${DOCKERFILE}" ]]; then
        echo "${DOCKERFILE} found."

        # Extract the image name and version from the line starting with FROM
        while IFS= read -r line; do
            if [[ $line =~ ^FROM\ ([^:]+):([^ ]+) ]]; then
                image_name="${BASH_REMATCH[1]}"
                version="${BASH_REMATCH[2]}"
                echo "Image: $image_name, Version: $version"
                export NEW_IMAGE_TAG=${version}
                break
            fi
        done < "$SCRIPTPATH/${DOCKERFILE}"
        
    else
        echo "Info: ${DOCKERFILE} not found."
        NEW_IMAGE_TAG=${1:-latest}
    fi
    
    IMAGE_NAME=${IMAGE_NAME:-$(basename $(realpath "$(pwd)/.."))}
    #IMAGE=${IMAGE_NAME}:${IMAGE_TAG}
    podman_login

    echo "IMAGE_TAG: $IMAGE_TAG / IMAGE_NAME: $IMAGE_NAME / NEW_IMAGE_TAG: ${NEW_IMAGE_TAG:-latest}"

    podman_upload "${IMAGE_TAG}" "${IMAGE_NAME}" "${NEW_IMAGE_TAG:-latest}"
}

[ "$SOURCE_AS_LIB" == "1" ] && return 0

set_vars

function usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -b, --build          Run the build process"
    echo "  -e, --export         Export the image from the container"
    echo "  -p, --push           Push image to github ${GITHUB_REGISTRY}"
    echo "  -b -e -p             Run the build process, export and publish"
    echo "  -t, --terminal       Open a terminal in the build container"
    echo "  -r, --run-ansible    Run Ansible playbook in the build container"
    echo "  -i, --export-image   Export the image with a specific tag"
    echo "  -c, --connect        Connect to the builder VM"
    echo "  -h, --help       Show this help message"
}

# Option parsing
while [[ "$#" -gt 0 ]]; do
    case $1 in
        
        -b|--build)        run_build;;
        -e|--export)       export_image;;
        -i|--export-image) export_image;;
        -p|--push)         push_image;;

        -t|--terminal)     run_terminal; exit 0 ;;
        -r|--run-ansible)  run_ansible_in_container; exit 0 ;;
        -c|--connect)      connect_builder; exit 0 ;;
        -h|--help)      usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
    shift
done