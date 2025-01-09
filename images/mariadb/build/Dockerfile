#FROM percona:8.0.36-28-centos
FROM mariadb:11.6.2-noble

USER root
VOLUME /var/lib/mysql /var/log/mysql
ENV TZ=Europe/Berlin 

COPY ./files/setup.sh /tmp/setup.sh

USER root
RUN date &&\
    chmod +x /tmp/setup.sh 
    
RUN date && \
    /bin/bash /tmp/setup.sh

COPY ./files/healthweb.sh  /var/www/html/
COPY ./files/00-healthweb.conf /etc/lighttpd/conf-enabled/

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./files/docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 3306
USER root
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "mariadbd" ]