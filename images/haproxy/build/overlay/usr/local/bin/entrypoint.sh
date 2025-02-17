#!/bin/sh
set -eu

# adapted from https://github.com/discourse/discourse_docker/blob/master/image/base/boot
# this script becomes PID 1 inside the container, catches termination signals, and stops
# processes managed by runit

export INTERNAL_HOST_IP=$(ip route show default | awk '/default/ {print $3}')

shutdown() {
  echo Shutting Down
  ls /etc/service | SHELL=/bin/sh parallel --no-notice sv force-stop {}
  if [ -e "/proc/${RUNSVDIR}" ]; then
    kill -HUP "${RUNSVDIR}"
    wait "${RUNSVDIR}"
  fi

  # give stuff a bit of time to finish
  sleep 1

  ORPHANS=$(ps -eo pid= | tr -d ' ' | grep -Fxv 1)
  SHELL=/bin/bash parallel --no-notice 'timeout 5 /bin/bash -c "kill {} && wait {}" || kill -9 {}' ::: "${ORPHANS}" 2> /dev/null
  exit
}

main() {
	echo "# $0 Starting ..." "$@"
	date
	echo "Args: $@"
	echo "INTERNAL_HOST_IP: $INTERNAL_HOST_IP / Image Build: $(cat /version.txt)"
	echo "----------------"
	ls -alR /etc/sv/
	echo "----------------"
	ls -alR /etc/service/
	echo "----------------"
	echo Staring services ...
	exec runsvdir -P /etc/service &
	RUNSVDIR=$!
	echo "Started runsvdir, PID is ${RUNSVDIR}"

	logger -d -n 127.0.0.1 -p local0.info "$(date) Started rsyslog ... "

	trap shutdown TERM HUP INT
	wait "${RUNSVDIR}"

}

# Remove pid files

echo -n "Removing rsyslogd PID file before starting it ..."
(rm -f /var/run/rsyslogd.pid || true)
echo "OK"


main
shutdown