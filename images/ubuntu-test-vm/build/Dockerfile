# Build an example Docker container image.
FROM ubuntu:24.04
LABEL maintainer="Robert Thurnreiter"

ARG IMAGE_BUILD
ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=Europe/Berlin 

RUN echo "Image-build: $IMAGE_BUILD" && \
    apt update &&\
    apt install -y software-properties-common &&\
    add-apt-repository --yes --update ppa:ansible/ansible &&\
    apt install -y python3-pexpect ansible

#RUN echo "Image-build: $IMAGE_BUILD" && \
#    apt install -y software-properties-common &&\
#    add-apt-repository --yes --update ppa:ansible/ansible &&\
#    apt install -y ansible

COPY ansible.cfg playbook.yml full-distro.yml sshd.yml sudoers.yml bootstrap.yml cleanup.yml users.yml /etc/ansible/

RUN ansible-playbook /etc/ansible/playbook.yml --connection=local -v && \
    rm -rf /etc/ansible/


COPY docker-entrypoint.sh /

USER root

EXPOSE 22
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["/bin/bash"]
