#!/bin/bash

if [ ! -d "/var/lib/mysql/mysql" ]; then
	cp -a /var/lib/mysql.bak/* /var/lib/mysql/
fi


exec /usr/bin/supervisord -n
