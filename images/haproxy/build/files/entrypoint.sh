#!/bin/sh
set -e

set -o errexit
set -o nounset
ulimit -n 1048576
readonly RSYSLOG_PID="/run/rsyslogd/rsyslogd.pid"
#readonly RSYSLOG_PID="/tmp/rsyslogd.pid"
#readonly RSYSLOG_DEBUGLOG="/var/log/rsyslogd/rsyslogd_debug.log"

export INTERNAL_HOST_IP=$(ip route show default | awk '/default/ {print $3}')

echo "Args: $@"
echo "INTERNAL_HOST_IP: $INTERNAL_HOST_IP / Image Build: $(cat /version.txt)"

#set -x

main() {
	echo "# $0 Starting ..." "$@"
	date
  	start_rsyslogd
  	start_lb "$@"

}

# make sure we have rsyslogd's pid file not
# created before
start_rsyslogd() {
	echo "# start_rsyslogd $RSYSLOG_PID"
	mkdir -p /var/log/haproxy
	rm -f $RSYSLOG_PID
	rsyslogd -f /etc/rsyslog.conf -i $RSYSLOG_PID
	echo "# done start_rsyslogd PID: $(cat $RSYSLOG_PID)"
	logger -d -n 127.0.0.1 -p local0.info "$(date) Started rsyslog ... $RSYSLOG_PID"
	
	tail -f /var/log/haproxy/haproxy.log &
}

# Starts the load-balancer (haproxy) with 
# whatever arguments we pass to it ("$@")
start_lb() {
	echo "start_lb" "$@"
	#  exec haproxy "$@"
	# first arg is `-f` or `--some-option`
	if [ "${1#-}" != "$1" ]; then
	        set -- haproxy "$@"
	fi
	
	if [ "$1" = 'haproxy' ]; then
	        shift # "haproxy"
	        # if the user wants "haproxy", let's add a couple useful flags
	        #   -W  -- "master-worker mode" (similar to the old "haproxy-systemd-wrapper"; allows for reload via "SIGUSR2")
	        #   -db -- disables background mode
	        set -- haproxy -W -db "$@"
	fi
	
	exec "$@"
}

main "$@"