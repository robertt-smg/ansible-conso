#!/bin/bash

echo "Install xdebug into php"

XDEBUG_INI=$(cat <<EOF
zend_extension=/opt/bitnami/php/lib/php/extensions/xdebug.so
[xdebug]
	#zend_extension=xdebug
	xdebug.max_nesting_level=4096
	xdebug.mode=debug,develop
	
	xdebug.client_host=$XDEBUG_HOST
	xdebug.client_port=$XDEBUG_PORT
	xdebug.start_with_request=yes
	xdebug.discover_client_host=1
	xdebug.log=/var/log/php-xdebug.log


	xdebug.default_enable=0
	xdebug.remote_enable=0
	xdebug.remote_handler=dbgp
	xdebug.remote_host=$XDEBUG_HOST
	xdebug.remote_connect_back=0
	xdebug.remote_port=$XDEBUG_PORT
	xdebug.remote_autostart=0
	xdebug.remote_log=/var/log/php-xdebug.log
	xdebug.trace_output_dir=/dev/null

EOF
)

touch /var/log/php-xdebug.log
chmod a+rw /var/log/php-xdebug.log

if [ "$1" == "--from-source" ]; then

	apt install php-xdebug

else

	if [ "$1" == "--from-source" ]; then
		# curl -sS http://xdebug.org/files/xdebug-2.8.1.tgz> /tmp/xdebug-2.8.1.tgz
		# curl -s https://xdebug.org/files/xdebug-3.1.3.tgz  -o /tmp/xdebug-3.1.3.tgz
		curl -s https://xdebug.org/files/xdebug-3.4.2.tgz  -o /tmp/xdebug-3.4.2.tgz

		apt-get -y install build-essential autoconf automake
		pushd .
		mkdir -p /usr/src/php/ext/
		# tar -xvzf /tmp/xdebug-2.8.1.tgz -C /usr/src/php/ext/
		# tar -xvzf /tmp/xdebug-3.1.3.tgz -C /usr/src/php/ext/
		tar -xvzf /tmp/xdebug-3.4.2.tgz -C /usr/src/php/ext/
		phpize
		make
		#???cp modules/xdebug.so /usr/local/lib/php/extensions/no-debug-non-zts-20160303/
		make install
		popd
	else

		# pecl install xdebug-2.8.1
		# pecl install xdebug-3.1.3
		apt-get -y install build-essential autoconf automake
		pecl channel-update pecl.php.net
		pecl install xdebug-3.4.2
	fi
fi
# docker-php-ext-configure xdebug-2.8.1
# docker-php-ext-install xdebug-2.8.1
# docker-php-ext-enable xdebug


echo "${XDEBUG_INI}" | tee --append /opt/bitnami/php/etc/conf.d/docker-php-ext-xdebug.ini
