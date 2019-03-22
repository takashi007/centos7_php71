#!/bin/bash -e

sed -i -r 's/inet_interfaces = localhost/'"inet_interfaces = all"'/g' /etc/postfix/main.cf

/usr/sbin/postfix start
php-fpm -F
