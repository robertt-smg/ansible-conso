#FROM percona:8.0.36-28-centos
FROM sosberlin/js7:joc-2-7-2

VOLUME /var/lib/mysql /var/log/mysql
ENV TZ=Europe/Berlin 

COPY ./files/setup.sh /tmp/setup.sh

USER root
RUN date &&\
    chmod +x /tmp/setup.sh 
    
RUN date && \
    /bin/bash /tmp/setup.sh

