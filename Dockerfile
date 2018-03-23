FROM centos
ENV PHP_VERSION php-7.2.3
ENV REDIS_VERSION redis-3.1.5
ENV SWOOLE_VERSION swoole-2.1.0
ENV MONGODB_VERSION mongodb-1.3.4
WORKDIR /root
RUN yum install -y vim wget
RUN wget http://cn2.php.net/distributions/"${PHP_VERSION}".tar.gz && tar -zxvf "${PHP_VERSION}".tar.gz
WORKDIR /root/"${PHP_VERSION}"
RUN ls -al
RUN cp php.ini-development /usr/local/"${PHP_VERSION}"/etc/php.ini && cp /usr/local/"${PHP_VERSION}"/etc/php-fpm.conf.default /usr/local/"${PHP_VERSION}"/etc/php-fpm.conf && cp /usr/local/"${PHP_VERSION}"/etc/php-fpm.d/www.conf.default /usr/local/"${PHP_VERSION}"/etc/php-fpm.d/www.conf
RUN ln -s /usr/local/"${PHP_VERSION}"/bin/phpize /usr/bin && ln -s /usr/local/"${PHP_VERSION}"/bin/php /usr/bin && ln -s /usr/local/"${PHP_VERSION}"/bin/php-config /usr/bin
#还需加入将php-fpm写入systemctl管理
WORKDIR /root
RUN wget http://pecl.php.net/get/"${REDIS_VERSION}".tgz && tar -zxvf "${REDIS_VERSION}".tgz
WORKDIR /root/"${REDIS_VERSION}"
RUN phpize && ./configure && make && make install && echo "extension=redis.so" >> /usr/local/"${PHP_VERSION}"/etc/php.ini

WORKDIR /root
RUN wget http://pecl.php.net/get/"${SWOOLE_VERSION}".tgz && tar -zxvf "${SWOOLE_VERSION}".tgz
WORKDIR /root/"${SWOOLE_VERSION}"
RUN phpize && ./configure && make && make install && echo "extension=swoole.so" >> /usr/local/"${PHP_VERSION}"/etc/php.ini

WORKDIR /root
RUN wget http://pecl.php.net/get/"${MONGODB_VERSION}".tgz && tar -zxvf "${MONGODB_VERSION}".tgz
WORKDIR /root/"${MONGODB_VERSION}"
RUN phpize && ./configure && make && make install && echo "extension=mongodb.so" >> /usr/local/"${PHP_VERSION}"/etc/php.ini

WORKDIR /root
RUN wget http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm && yum -y localinstall mysql57-community-release-el7-8.noarch.rpm && yum install -y mysql-community-server

RUN yum -y install nginx redis

WORKDIR /root