FROM php:7.0-alpine
COPY . /usr/src/myapp
WORKDIR /usr/src/myapp

# use mirror tsinghua
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

RUN set -xe \
	&& apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
	&& export CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS" \
	&& pecl install redis \
    && pecl install apcu \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install gd \
    && pecl install imagick\
    && docker-php-ext-install mcrypt \
    && pecl install memcached \
    && pecl install mongodb \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install shmop \
    && docker-php-ext-install soap \
    && docker-php-ext-install sockets \
    && docker-php-ext-install sysvsem \
    && docker-php-ext-install xmlrpc \
    && docker-php-ext-install opcache \
    && docker-php-ext-install zip \
    && pecl install swoole \
    && pecl install xdebug \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable apcu \
    && docker-php-ext-enable bcmath \
    && docker-php-ext-enable gd \
    && docker-php-ext-enable imagick\
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-enable memcached \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-enable mysqli \
    && docker-php-ext-enable pcntl \
    && docker-php-ext-enable pdo_mysql \
    && docker-php-ext-enable shmop \
    && docker-php-ext-enable soap \
    && docker-php-ext-enable sockets \
    && docker-php-ext-enable sysvsem \
    && docker-php-ext-enable xmlrpc \
    && docker-php-ext-enable opcache\ 
    && docker-php-ext-enable zip \
    && docker-php-ext-enable swoole \
    && docker-php-ext-enable xdebug \
    && rm /tmp/* -rf
CMD [ "php", "./index.php" ]