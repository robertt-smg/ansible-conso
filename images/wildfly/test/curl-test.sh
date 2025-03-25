#!/bin/bash
URL="http://127.0.0.180:8080/neoCore/XmlServlet"
source curl-test.secrets.sh
while true; do
    curl --location -X POST $URL \
    --header 'Content-Type: text/xml; charset=utf-8' \
    --header "Authorization: ${AUTHORIZATION}" \
    --data-raw '<ping/>' \
    -w "@curl-format.txt" -o /dev/null
    sleep 1
    clear
    
done