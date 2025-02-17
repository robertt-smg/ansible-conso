#!/bin/bash
URL="http://aqnode.prd.vagrant:8080/neoCore/XmlServlet"
#URL="http://aqnode.prd.muc01.fti.int:8080/neoCore/XmlServlet"

while true; do
    curl --location -X POST $URL \
    --header 'Content-Type: text/xml; charset=utf-8' \
    --header 'Authorization: bGVlbG9vO211bHRpcGFzcw==' \
    --data-raw '<ping/>' \
    -w "@curl-format.txt" -o /dev/null
    sleep 1
    clear
    
done