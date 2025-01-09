#FROM percona:8.0.36-28-centos
FROM bitnami/percona-mysql:8.0.39-30-debian-12-r3

VOLUME /var/lib/mysql /var/log/mysql
ENV TZ=Europe/Berlin 

COPY ./files/setup.sh /tmp/setup.sh

USER root
RUN date &&\
    chmod +x /tmp/setup.sh 
    
RUN date && \
    /bin/bash /tmp/setup.sh


#USER mysql
#EXPOSE 3306 33060
#CMD ["mysqld"]
#ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3306
USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/mysql/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/mysql/run.sh" ]

