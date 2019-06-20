FROM php:7.0-alpine
COPY . /usr/src/myapp
WORKDIR /usr/src/myapp

# use mirror tsinghua
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

RUN pecl install redis \
	&& pecl install swoole \
        && docker-php-ext-enable redis \
        && docker-php-ext-enable swoole \
	&& rm /tmp/* -rf
CMD [ "php", "./index.php" ]