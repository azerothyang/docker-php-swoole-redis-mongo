FROM centos
LABEL maintainer "Yang Cheng"
ENV PHP_VERSION php-7.2.5
ENV REDIS_VERSION redis-3.1.5
ENV SWOOLE_VERSION swoole-4.0.2
ENV MONGODB_VERSION mongodb-1.3.4
ENV FREETYPE_VERSION freetype-2.9
ENV SWOOLE_LOCAL_DIR /mnt/policy2/microservice/php/es2/

# init
WORKDIR /root
RUN yum -y install vim wget git gcc glibc-headers gcc-c++ libmcrypt libmcrypt-devel autoconf freetype gd jpegsrc libmcrypt libpng libpng-devel libjpeg libxml2 libxml2-devel zlib curl curl-devel openssl*
RUN wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && rpm -ivh epel-release-latest-7.noarch.rpm && yum clean all && yum -y update
#donwload php and install php
RUN wget http://cn2.php.net/distributions/"${PHP_VERSION}".tar.gz && tar -zxvf "${PHP_VERSION}".tar.gz
WORKDIR /root/"${PHP_VERSION}"
RUN ./configure --prefix=/usr/local/"${PHP_VERSION}" --with-mysql-sock=/var/run/mysql/mysql.sock --with-mhash --with-openssl --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv --with-zlib --enable-zip --enable-inline-optimization --disable-fileinfo --enable-shared --enable-bcmath --enable-shmop --enable-sysvsem --enable-mbregex --enable-mbstring --enable-ftp --enable-pcntl --enable-sockets --with-xmlrpc --enable-soap --with-gettext --enable-session --with-curl --enable-opcache --enable-fpm --with-config-file-path=/usr/local/"${PHP_VERSION}"/etc/ && make && make install

RUN cp php.ini-development /usr/local/"${PHP_VERSION}"/etc/php.ini && cp /usr/local/"${PHP_VERSION}"/etc/php-fpm.conf.default /usr/local/"${PHP_VERSION}"/etc/php-fpm.conf && cp /usr/local/"${PHP_VERSION}"/etc/php-fpm.d/www.conf.default /usr/local/"${PHP_VERSION}"/etc/php-fpm.d/www.conf
RUN ln -s /usr/local/"${PHP_VERSION}"/bin/phpize /usr/bin && ln -s /usr/local/"${PHP_VERSION}"/bin/php /usr/bin && ln -s /usr/local/"${PHP_VERSION}"/bin/php-config /usr/bin

#install freetype-2.9 and gd

#install freetype
WORKDIR /root
RUN wget https://download.savannah.gnu.org/releases/freetype/"${FREETYPE_VERSION}".tar.gz && tar -zxvf "${FREETYPE_VERSION}".tar.gz
WORKDIR /root/"${FREETYPE_VERSION}"
RUN sh configure --prefix=/usr/local/"${FREETYPE_VERSION}" && make && make install && ln -s /usr/local/"${FREETYPE_VERSION}"/include/freetype2/freetype/ /usr/local/include/ && ln -s /usr/local/"${FREETYPE_VERSION}"/include/freetype2/ft2build.h /usr/local/include

#install gd
WORKDIR /root/"${PHP_VERSION}"/ext/gd
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

# RUN wget http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm && yum -y localinstall mysql57-community-release-el7-8.noarch.rpm && yum install -y mysql-community-server

#expose port 9501
EXPOSE 9501

#create easyswoole dir
WORKDIR /mnt/

#开发完成后, 将开发机器上的文件全部拷贝到容器里的easyswoole目录下,打包成镜像发布
#COPY SWOOLE_LOCAL_DIR /mnt/

ENTRYPOINT php easyswoole start

#最后通过映射端口和挂载volume开发： docker run  -p 80:9501 -v /mnt/swoole/:/mnt/ -d registry.xx.com。 
