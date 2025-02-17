# Use latest jboss/base-jdk:8 image as the base
#FROM jboss/base-jdk:11
FROM rockylinux:9.1

USER root
RUN id && rm /etc/localtime \
	&& ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

USER jboss
ARG IMAGE_BUILD

# Set the WILDFLY_VERSION env variable

ENV WILDFLY_VERSION 27.0.1.Final
ENV WILDFLY_SHA1 a747cec6cf347bd71aeeabecc0e0856e6b431c6c
##

ENV JBOSS_HOME /opt/jboss/wildfly
ENV LISTEN_ADDR 0.0.0.0
#ENV JAVA_OPTIONS=-Dlog4j2.formatMsgNoLookups=true

ENV JAVA_OPTIONS="-Dlog4j2.formatMsgNoLookups=true -Xms8g -Xmx8g -XX:+UseG1GC -XX:ConcGCThreads=12 -XX:ParallelGCThreads=22 -XX:MaxGCPauseMillis=1000 -XX:InitiatingHeapOccupancyPercent=40 -XX:G1HeapWastePercent=2 -XX:G1ReservePercent=15 -XX:+UnlockExperimentalVMOptions -XX:G1OldCSetRegionThresholdPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=20 -XX:G1MaxNewSizePercent=25"
# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true
# Expose the ports we're interested in
EXPOSE 8080
EXPOSE 9990

USER root

RUN dnf -q  --security check-update | true
RUN dnf install -y java-17-openjdk java-17-openjdk-devel xmlstarlet  augeas bsdtar unzip

RUN groupadd -r jboss -g 1000 && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss && \
    chmod 755 /opt/jboss

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
## https://download.jboss.org/wildfly/20.0.1.Final/wildfly-20.0.1.Final.tar.gz
## https://github.com/wildfly/wildfly/releases/download/27.0.0.Final/wildfly-27.0.0.Final.tar.gz
## https://download.jboss.org/wildfly/24.0.1.Final/wildfly-preview-24.0.1.Final.tar.gz
## https://download.jboss.org/wildfly/24.0.1.Final/wildfly-24.0.1.Final.tar.gz

## && curl -O https://github.com/wildfly/wildfly/releases/download/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz -L \

RUN echo $IMAGE_BUILD && echo "Downloading and installing ..." \
    \ ## curl  -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz -L \
	&& curl  -O https://github.com/wildfly/wildfly/releases/download/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz -L \
	&& sha1sum wildfly-$WILDFLY_VERSION.tar.gz  \
	&& sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1  \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz --directory /opt/jboss/ \
	&& mv /opt/jboss/wildfly-$WILDFLY_VERSION /opt/jboss/wildfly/ \
    && rm wildfly-$WILDFLY_VERSION.tar.gz

ADD customization /tmp/app/customization/ 
ADD neoAPI.war /tmp/app/standalone/deployments/ 
ADD neoCoreWar-0.0.31.war /tmp/app/standalone/deployments/ 
ADD node-info.war /tmp/app/standalone/deployments/ 
ADD mysql-connector-java-8.0.23.jar /tmp/app/standalone/deployments/ 
ADD mariadb-java-client-3.1.0.jar /tmp/app/standalone/deployments/ 
#ADD neoCore-NDC-1.2.war /tmp/app/standalone/deployments/ 
ADD log4j-web-2.20.0.jar /tmp/app/standalone/deployments/ 
ADD log4j2.xml /tmp/app/standalone/deployments/ 
ADD	modules /tmp/app/modules/

RUN echo $IMAGE_BUILD \
		&& cp -r /tmp/app/* /opt/jboss/wildfly \
	    && mkdir -p /opt/jboss/wildfly/standalone/data/content \
	    && chmod -R go+rX /opt/jboss/wildfly \
	    && chown -R jboss:jboss /opt/jboss/wildfly \
	    && chown -R jboss:jboss /opt/jboss/wildfly/standalone \
		&& ls /opt/jboss/wildfly \
		&& /opt/jboss/wildfly/bin/add-user.sh admin admin1234 \
	    && chmod +x /opt/jboss/wildfly/customization/execute.sh \
	    && echo "JAVA_OPTIONS=-Dlog4j2.formatMsgNoLookups=true" >> /etc/environment \
		&& echo done
		
USER jboss
		
VOLUME /opt/jboss/wildfly/standalone/log
		
WORKDIR /opt/jboss
USER jboss

CMD [ "/opt/jboss/wildfly/bin/standalone.sh", "-Dlog4j2.formatMsgNoLookups=true", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]

