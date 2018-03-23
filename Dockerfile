﻿FROM centos
ENV PHP_VERSION php-7.2.3
ENV REDIS_VERSION redis-3.1.5
ENV SWOOLE_VERSION swoole-2.1.0
ENV MONGODB_VERSION mongodb-1.3.4
WORKDIR /root
RUN yum install -y vim wget
RUN wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && rpm -ivh epel-release-latest-7.noarch.rpm && yum clean all && yum -y update
RUN yum -y install gcc libmcrypt libmcrypt-devel autoconf freetype gd jpegsrc libmcrypt libpng libpng-devel libjpeg libxml2 libxml2-devel zlib curl curl-devel openssl*
RUN wget http://cn2.php.net/distributions/"${PHP_VERSION}".tar.gz && tar -zxvf "${PHP_VERSION}".tar.gz
WORKDIR /root/"${PHP_VERSION}"
RUN ls -al
RUN ./configure --prefix=/usr/local/"${PHP_VERSION}" --with-mysql-sock=/var/run/mysql/mysql.sock --with-mhash --with-openssl -with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-gd --with-iconv --with-zlib --enable-zip --enable-inline-optimization --disable-fileinfo --enable-shared --enable-bcmath --enable-shmop --enable-sysvsem --enable-mbregex --enable-mbstring --enable-ftp --enable-pcntl --enable-sockets --with-xmlrpc --enable-soap --with-gettext --enable-session --with-curl --enable-opcache --enable-fpm --with-config-file-path=/usr/local/"${PHP_VERSION}"/etc/ && make && make install
RUN cp php.ini-development /usr/local/"${PHP_VERSION}"/etc/php.ini && cp /usr/local/"${PHP_VERSION}"/etc/php-fpm.conf.default /usr/local/"${PHP_VERSION}"/etc/php-fpm.conf && cp /usr/local/"${PHP_VERSION}"/etc/php-fpm.d/www.conf.default /usr/local/"${PHP_VERSION}"/etc/php-fpm.d/www.conf
RUN ln -s /usr/local/"${PHP_VERSION}"/bin/phpize /usr/bin && ln -s /usr/local/"${PHP_VERSION}"/bin/php /usr/bin && ln -s /usr/local/"${PHP_VERSION}"/bin/php-config /usr/bin
#need to link php-fpm to systemctl to control
WORKDIR /root
RUN wget http://pecl.php.net/get/"${REDIS_VERSION}".tgz && tar -zxvf "${REDIS_VERSION}".tgz
WORKDIR /root/"${REDIS_VERSION}" 
RUN phpize && ./configure && make && make install && echo "extension=redis.so\n" >> /usr/local/"${PHP_VERSION}"/etc/php.ini 

WORKDIR /root
RUN wget http://pecl.php.net/get/"${SWOOLE_VERSION}".tgz && tar -zxvf "${SWOOLE_VERSION}".tgz         
WORKDIR /root/"${SWOOLE_VERSION}"
RUN phpize && ./configure && make && make install && echo "extension=swoole.so\n" >> /usr/local/"${PHP_VERSION}"/etc/php.ini

WORKDIR /root
RUN wget http://pecl.php.net/get/"${MONGODB_VERSION}".tgz && tar -zxvf "${MONGODB_VERSION}".tgz
WORKDIR /root/"${MONGODB_VERSION}"
RUN phpize && ./configure && make && make install && echo "extension=mongodb.so\n" >> /usr/local/"${PHP_VERSION}"/etc/php.ini

RUN yum -y install nginx && systemctl start nginx
RUN setenforce 0 && systemctl stop firewalld.service && systemctl disable firewalld.service