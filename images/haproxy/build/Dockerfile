FROM haproxy:3.0

VOLUME /usr/local/etc/haproxy
ENV TZ=Europe/Berlin 

USER root

COPY files/entrypoint.sh /usr/local/bin/entrypoint

COPY ./files/haproxy.cfg /usr/local/etc/haproxy/ 
COPY ./files/200welcome.http /usr/local/http/200welcome.http
COPY ./files/rsyslog.conf /etc/
COPY ./files/setup.sh /tmp/setup.sh

RUN date &&\
    chmod +x /usr/local/bin/entrypoint && \
    chmod +x /tmp/setup.sh 
    
RUN date && \
    /bin/bash /tmp/setup.sh

EXPOSE 8690 8691 8692 8080 8043 443
# 
## 
USER haproxy

ENTRYPOINT [ "/usr/local/bin/entrypoint" ]

# Make haproxy use the default configuration file
CMD [ "haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
