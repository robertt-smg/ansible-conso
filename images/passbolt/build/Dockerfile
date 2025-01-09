FROM passbolt/passbolt:4.9.1-1-ce

COPY files/run.sh /run.sh
COPY files/register-admin-user.sh /register-admin-user.sh

RUN date && \
    apt-get update &&\
    mkdir /gpg && \
    mkdir /jwt && \
    rm -rf /etc/passbolt/gpg && \
    mkdir -p /etc/passbolt/jwt && \
    chmod +x /run.sh && \
    date > /version.txt 

ENTRYPOINT [ "/bin/bash", "/run.sh" ]
CMD [  ]
