FROM php:7.0-alpine

WORKDIR /usr/src/myapp
COPY index.php index.php

# use mirror tsinghua
# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \

RUN apk update \
    && apk add --no-cache gd-dev libpng-dev \
        libmcrypt-dev \
        libxml2-dev \
        imagemagick6-dev \
        libmemcached-dev \
        tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        
    && export CFLAGS="$PHP_CFLAGS" \
        CPPFLAGS="$PHP_CPPFLAGS" \
        LDFLAGS="$PHP_LDFLAGS" \
    && pecl install redis \
    && pecl install apcu \
    && docker-php-ext-install bcmath gd mcrypt \
        mysqli pcntl pdo_mysql shmop soap sockets sysvsem xmlrpc opcache zip \
    && docker-php-ext-install gd \
    && pecl install imagick \
    && docker-php-ext-install mcrypt \
    && pecl install memcached \
    && pecl install mongodb \
#   && pecl install swoole \
#   && pecl install xdebug \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable apcu \
    && docker-php-ext-enable gd \
    && docker-php-ext-enable imagick \
    && docker-php-ext-enable memcached \
    && docker-php-ext-enable mongodb \
#   && docker-php-ext-enable swoole \
#   && docker-php-ext-enable xdebug \
# Chane TimeZone   
#   && cp $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini \
    && cp $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini \
    && sed -i 's/;date.timezone =/date.timezone = "Asia\/Shanghai"/g' $PHP_INI_DIR/php.ini \
    && apk del .build-deps \
    && rm /tmp/* -rf

# install composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# CMD [ "php", "./index.php" ]