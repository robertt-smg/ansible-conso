#!/bin/bash
URL="https://neocore.test.smg-air-conso.com/neoCore/XmlServlet"
source curl-test.secrets.sh

curl -v  --insecure --location -X POST $URL \
--header 'Content-Type: text/xml; charset=utf-8' \
--header "Authorization: ${AUTHORIZATION}" \
--data-raw '<ping/>' \
-w "@curl-format.txt" 
