# docker-php-rc

## Build Status
[![Docker Repository on Quay](https://quay.io/repository/lzh1104/php-rc/status "Docker Repository on Quay")](https://quay.io/repository/lzh1104/php-rc)
[![php 8.2](https://github.com/lzh1104/docker-php-rc/actions/workflows/php-8.2.yml/badge.svg)](https://github.com/lzh1104/docker-php-rc/actions/workflows/php-8.2.yml)
[![php 8.4](https://github.com/lzh1104/docker-php-rc/actions/workflows/php-8.4.yml/badge.svg)](https://github.com/lzh1104/docker-php-rc/actions/workflows/php-8.4.yml)
## php version
  `7.0`  `8.2-fpm` `8.4-zts`

## add ext
`apcu` `bcmath` `gd` `imagick` `mcrypt` `pcntl` `pdo_mysql` `mysqli` `shmop` `soap`
`sockets` `sysvsem` `xmlrpc` `opcache` ` zip`
 `redis` `memcached` `mongodb` `swoole`

[php -m](phpm.md)

## add
`composer`

## build
`sudo docker build -t lzh1104/php-rc:8.2-fpm-sqlsrv -f Dockerfile.8.2-fpm-sqlsrv --build-arg USE_CHINA=tuna .`

## run
```
docker run --it --rm lzh1104/php-rc:8.1-fpm php -m
```

## timezone
```
Asis/Shanghai
```
