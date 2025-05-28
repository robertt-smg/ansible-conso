FROM vimagick/tinyproxy

ENV TZ=Europe/Berlin 

COPY ./files/setup.sh /tmp/setup.sh

USER root
RUN date &&\
    chmod +x /tmp/setup.sh 
    
RUN date && \
    /bin/sh /tmp/setup.sh

