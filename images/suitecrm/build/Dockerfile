FROM docker.io/bitnami/suitecrm:8

COPY ./files/setup.sh /tmp/setup.sh
COPY files/run.sh /run.sh
COPY ./files/wait-for.sh /usr/bin/wait-for.sh

USER root
RUN date && \
    apt-get update &&\
    chmod +x /tmp/setup.sh /usr/bin/wait-for.sh /run.sh 

EXPOSE 8080 8443

ENTRYPOINT [ "/bin/bash", "/run.sh" ]
CMD [ "/opt/bitnami/scripts/suitecrm/run.sh" ]
