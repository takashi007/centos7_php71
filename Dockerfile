FROM centos:centos7

ENV PHP_INI_DIR="/etc"
ENV PHP_TIMEZONE="Asia/Tokyo"

RUN curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash -s -- --mariadb-server-version=mariadb-10.2

RUN yum update -y \
  && yum install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm -y \
  && yum-config-manager --enable remi-php71 \
  && yum -y install make \
  && yum -y install gcc \
  && yum -y install gcc-c++ \
  && yum -y install autoconf \
  && yum -y install automake \
  && yum -y install git \
  && yum -y install vim \
  && yum -y install zip \
  && yum -y install unzip \
  && yum -y install php \
  && yum -y install php-fpm \
  && yum -y install php-pdo \
  && yum -y install php-mysql \
  && yum -y install php-pdo \
  && yum -y install php-xml \
  && yum -y install php-devel \
  && yum -y install php-pear \
  && yum -y install php-gmp \
  && yum -y install php-mbstring \
  && yum -y install php-intl \
  && yum -y install php-opcache \
  && yum -y install php-pecl-apcu \
  && yum -y install yum-cron \
  && yum -y install MariaDB-client \
  && yum -y install postfix \
  && yum clean all

#ADD postfix/main.cf /etc/postfix/main.cf
#ADD postfix/master.cf /etc/postfix/master.cf

RUN pecl install xdebug

RUN echo "zend_extension=xdebug.so" > $PHP_INI_DIR/php.d/15-xdebug.ini

# Install Composer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html
RUN mkdir -p /var/run/php-fpm

RUN sed -i '/^listen.allowed_clients/c;listen.allowed_clients =' /etc/php-fpm.d/www.conf

RUN set -ex \
	&& cd /etc \
	&& { \
		echo '[global]'; \
		echo 'error_log = /proc/self/fd/2'; \
		echo; \
		echo '[www]'; \
		echo '; if we send this to /proc/self/fd/1, it never appears'; \
		echo 'access.log = /proc/self/fd/2'; \
		echo; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
	} | tee php-fpm.d/docker.conf \
	&& { \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo 'listen = 9000'; \
	} | tee php-fpm.d/zz-docker.conf

EXPOSE 9000

ADD launch.sh /launch.sh
CMD ["/launch.sh"]
