FROM alpine:3.21

ADD files /scripts

RUN date &&\
    chmod +x /scripts/*.sh && \
    apk update && \
    apk add bash && \
    apk add openssl && \
    /bin/bash /scripts/setup.sh

EXPOSE 139/tcp 445/tcp

#CMD ["smbd", "--foreground", "--debuglevel=10", "--debug-stdout", "--no-process-group"]
CMD ["smbd", "--foreground",  "--debug-stdout", "--no-process-group"]
