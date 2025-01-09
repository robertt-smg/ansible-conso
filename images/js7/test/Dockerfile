FROM mariadb:11.3.2

COPY install/ /tmp/install/
ARG IMAGE_BUILD

RUN echo $IMAGE_BUILD && ls -al /tmp/install && chmod +x /tmp/install/setup.sh && sync \
	&& /tmp/install/setup.sh 
