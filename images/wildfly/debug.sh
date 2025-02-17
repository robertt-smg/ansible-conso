#!/bin/bash
docker run --add-host aqdb1.prd.muc01.fti.int:192.168.33.1 -p 8080:8080 -p 9990:9990  -v /var/log/wildfly:/opt/jboss/wildfly/standalone/log --rm wildfly-aqneo
