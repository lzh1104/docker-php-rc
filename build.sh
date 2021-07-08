#!/bin/sh
. /etc/profile

# 参数：
# args[0] ,数据日期,日期格式yyyy-MM-dd

if [ $# == 1 ]; then
   tag=$1
else 
   tag="7.4-fpm"
fi

docker build -f Dockerfile.${tag} -t lzh1104/php-rc:${tag} .
docker push lzh1104/php-rc:${tag}