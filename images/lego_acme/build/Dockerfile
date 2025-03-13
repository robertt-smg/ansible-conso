FROM goacme/lego:v4.22 as builder

WORKDIR /usr/bin
RUN date 

FROM alpine:3

ENV USE_STAGING=1
ENV EMAIL=""
ENV CERT_PATH=/data/certs
ENV SECRETS_PATH=/data/secrets
ENV ALL_DOMAINS=""
ENV HAPROXY_HOST_ADMIN=""

ENV TZ=Europe/Berlin 

VOLUME [ "/data" ]

COPY --from=builder /lego /usr/bin/lego
ADD files /scripts

RUN date &&\
    chmod +x /scripts/*.sh && \
    apk update && \
    apk add bash && \
    apk add openssl && \
    /bin/bash /scripts/setup.sh

ENTRYPOINT [ "bash", "/scripts/get_lego_acme_certs.sh" ]
CMD [  ]
    