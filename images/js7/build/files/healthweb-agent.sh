#!/bin/bash

if /opt/sos-berlin.com/js7/agent/bin/agent_4445.sh status > /dev/null 2>&1; then
  echo "Status: 200 OK"
  echo "Content-Type: text/plain"
  echo ""
  echo "OK"
else
  echo "Status: 500 Internal Server Error"
  echo "Content-Type: text/plain"
  echo ""
  echo "Failed"
  exit 1
fi
