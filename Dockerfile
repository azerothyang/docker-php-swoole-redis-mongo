FROM centos
LABEL maintainer "Yang Cheng"
ENV PHP_VERSION php-7.2.5
ENV REDIS_VERSION redis-3.1.5
ENV SWOOLE_VERSION swoole-4.0.2
ENV MONGODB_VERSION mongodb-1.3.4
ENV FREETYPE_VERSION freetype-2.9

# init
WORKDIR /root
RUN yum install -y vim wget
RUN wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && rpm -ivh epel-release-latest-7.noarch.rpm && yum clean all && yum -y update
RUN yum -y install gcc libmcrypt libmcrypt-devel autoconf freetype gd jpegsrc libmcrypt libpng libpng-devel libjpeg libxml2 libxml2-devel zlib curl curl-devel openssl*

#donwload php and install php
RUN wget http://cn2.php.net/distributions/"${PHP_VERSION}".tar.gz && tar -zxvf "${PHP_VERSION}".tar.gz
WORKDIR /root/"${PHP_VERSION}"
RUN ./configure --prefix=/usr/local/"${PHP_VERSION}" --with-mysql-sock=/var/run/mysql/mysql.sock --with-mhash --with-openssl --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-gd --with-iconv --with-zlib --enable-zip --enable-inline-optimization --disable-fileinfo --enable-shared --enable-bcmath --enable-shmop --enable-sysvsem --enable-mbregex --enable-mbstring --enable-ftp --enable-pcntl --enable-sockets --with-xmlrpc --enable-soap --with-gettext --enable-session --with-curl --enable-opcache --enable-fpm --with-config-file-path=/usr/local/"${PHP_VERSION}"/etc/ && make && make install

RUN cp php.ini-development /usr/local/"${PHP_VERSION}"/etc/php.ini && cp /usr/local/"${PHP_VERSION}"/etc/php-fpm.conf.default /usr/local/"${PHP_VERSION}"/etc/php-fpm.conf && cp /usr/local/"${PHP_VERSION}"/etc/php-fpm.d/www.conf.default /usr/local/"${PHP_VERSION}"/etc/php-fpm.d/www.conf
RUN ln -s /usr/local/"${PHP_VERSION}"/bin/phpize /usr/bin && ln -s /usr/local/"${PHP_VERSION}"/bin/php /usr/bin && ln -s /usr/local/"${PHP_VERSION}"/bin/php-config /usr/bin

#install freetype-2.9 and gd

#install freetype
WORKDIR /root
RUN wget https://download.savannah.gnu.org/releases/freetype/"${FREETYPE_VERSION}".tar.gz && tar -zxvf "${FREETYPE_VERSION}".tar.gz
WORKDIR /"${FREETYPE_VERSION}"
RUN sh configure --prefix=/usr/local/"${FREETYPE_VERSION}" && make && make install

#install gd
WORKDIR /"${PHP_VERSION}"/ext/gd
RUN phpize && sh configure --with-freetype-dir=/usr/local/"${FREETYPE_VERSION}" && make && make install && echo "extension=gd.so" >> /usr/local/"${PHP_VERSION}"/etc/php.ini

# install php-redis
WORKDIR /root
RUN wget http://pecl.php.net/get/"${REDIS_VERSION}".tgz && tar -zxvf "${REDIS_VERSION}".tgz
WORKDIR /root/"${REDIS_VERSION}"
RUN phpize && sh configure && make && make install && echo "extension=redis.so" >> /usr/local/"${PHP_VERSION}"/etc/php.ini

# install php-swoole
WORKDIR /root
RUN wget http://pecl.php.net/get/"${SWOOLE_VERSION}".tgz && tar -zxvf "${SWOOLE_VERSION}".tgz
WORKDIR /root/"${SWOOLE_VERSION}"
RUN phpize && sh configure && make && make install && echo "extension=swoole.so" >> /usr/local/"${PHP_VERSION}"/etc/php.ini

#install php-mongodb
WORKDIR /root
RUN wget http://pecl.php.net/get/"${MONGODB_VERSION}".tgz && tar -zxvf "${MONGODB_VERSION}".tgz
WORKDIR /root/"${MONGODB_VERSION}"
RUN phpize && sh configure && make && make install && echo "extension=mongodb.so" >> /usr/local/"${PHP_VERSION}"/etc/php.ini

WORKDIR /root
# RUN wget http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm && yum -y localinstall mysql57-community-release-el7-8.noarch.rpm && yum install -y mysql-community-server

EXPOSE 9501
#将进入目录定位到/mnt
WORKDIR /mnt

#最后通过映射端口： docker run -it -p 80:9501 -v /mnt/es2/:/mnt/ registry.cn-shenzhen.aliyuncs.com/php-docker/php-docker-private php /mnt/bin/easyswoole start
