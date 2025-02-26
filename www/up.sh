#!/bin/bash

set -x
SCRIPT="$(readlink -f -- $0)"
SCRIPTPATH="$(dirname $SCRIPT)"

 busybox httpd -v -p 127.0.0.127 -h .
 start http://127.0.0.127