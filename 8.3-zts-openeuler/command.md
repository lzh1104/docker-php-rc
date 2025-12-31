# Dockerfile 手动执行命令指南

此文档记录了 Dockerfile 中每一步操作对应的手动执行命令。

## 1. 更换软件源并更新缓存

```bash
sed -i 's/repo.openeuler.org/mirrors.aliyun.com\/openeuler/g' /etc/yum.repos.d/openEuler.repo && dnf makecache
```

## 2. 启用 CRB 仓库

```bash
dnf config-manager --set-enabled crb || :
```

## 3. 安装 PHP 构建依赖

```bash
dnf install -y autoconf automake make file g++ gcc glibc-devel pkgconfig shadow-utils curl diffutils util-linux
```

## 4. 创建用户和目录

```bash
export PHP_INI_DIR=/usr/local/etc/php
groupadd -g 82 www-data
useradd -u 82 -g www-data -r -s /sbin/nologin -M www-data
mkdir -p /usr/local/etc/php/conf.d
[ ! -d /var/www/html ] && mkdir -p /var/www/html
chown www-data:www-data /var/www/html
chmod 1777 /var/www/html
```

## 5. 安装 GPG 并下载 PHP 源码

```bash
dnf install -y gnupg
mkdir -p /usr/src && cd /usr/src
curl -fsSL -o php.tar.xz "https://www.php.net/distributions/php-8.3.29.tar.xz"
echo "f7950ca034b15a78f5de9f1b22f4d9bad1dd497114d175cb1672a4ca78077af5 *php.tar.xz" | sha256sum -c -
curl -fsSL -o php.tar.xz.asc "https://www.php.net/distributions/php-8.3.29.tar.xz.asc"
export GNUPGHOME="$(mktemp -d)"
for key in 1198C0117593497A5EC5C199286AF1F9897469DC C28D937575603EB4ABB725861C0779DC5C0A9DE4 AFD8691FDAEDF03BDF6E460563F15A9B715376CA; do
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"
done
gpg --batch --verify php.tar.xz.asc php.tar.xz
gpgconf --kill all
rm -rf "$GNUPGHOME"
dnf remove -y $(rpm -qa | grep -v '^gpg\|^shadow\|^ca-certificates') || :
```

## 6. 安装并编译 libiconv

```bash
cd /usr/src
curl -fsSL -o libiconv-1.18.tar.gz https://mirrors.aliyun.com/gnu/libiconv/libiconv-1.18.tar.gz
tar -zxvf libiconv-1.18.tar.gz
cd libiconv-1.18
./configure --prefix=/usr
make
make install
cd ..
rm -rf libiconv-1.18
rm -rf libiconv-1.18.tar.gz
```

## 7. 复制并设置 docker-php-source 脚本权限

```bash
# 假设在宿主机的当前目录下有 docker-php-source 文件
cp /opt/src/docker-php-source /usr/local/bin/
chmod +x /usr/local/bin/docker-php-source
```

## 8. 安装 PHP 扩展依赖并编译 PHP

```bash
dnf install -y libargon2-devel libcurl-devel readline-devel oniguruma-devel libsodium-devel sqlite-devel openssl-devel libxml2-devel zlib-devel
export CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
export CPPFLAGS="$CFLAGS"
export LDFLAGS="-Wl,-O1 -pie"
export PHP_BUILD_PROVIDER='https://github.com/docker-library/php'
export PHP_UNAME='Linux - Docker'
docker-php-source extract
cd /usr/src/php
gnuArch="$(uname -m)"
libDir="lib"
if [ "$(uname -m)" = "aarch64" ]; then
    gnuArch="aarch64-linux-gnu"
    libDir="lib64"
elif [ "$(uname -m)" = "x86_64" ]; then
    gnuArch="x86_64-openEuler-linux"
    libDir="lib64"
fi
if [ ! -d /usr/include/curl ] && [ -d "/usr/include/$libDir" ]; then
    ln -sT "/usr/include/$libDir/curl" /usr/local/include/curl || :
fi
./configure \
    --build="$gnuArch" \
    --with-config-file-path="/usr/local/etc/php" \
    --with-config-file-scan-dir="/usr/local/etc/php/conf.d" \
    --enable-option-checking=fatal \
    --with-mhash \
    --with-pic \
    --enable-mbstring \
    --enable-mysqlnd \
    --with-password-argon2 \
    --with-sodium=shared \
    --with-pdo-sqlite=/usr \
    --with-sqlite3=/usr \
    --with-curl \
    --with-iconv=/usr/bin \
    --with-openssl \
    --with-readline \
    --with-zlib \
    --enable-phpdbg \
    --enable-phpdbg-readline \
    --with-pear \
    --with-libdir="$libDir" \
    --enable-embed \
    --enable-zts \
    --disable-zend-signals
make -j "$(nproc)"
find -type f -name '*.a' -delete
make install
find /usr/local -type f -perm '/0111' -exec sh -euxc 'strip --strip-all "$@" || :' -- '{}' +
make clean
cp -v php.ini-* "/usr/local/etc/php/"
cd /
docker-php-source delete
dnf remove -y $(rpm -qa | grep -v '^gpg\|^curl\|^xz\|^ca-certificates\|^libargon2\|^libcurl\|^readline\|^libsodium\|^sqlite\|^openssl\|^libxml2\|^zlib') || :
dnf clean all
pecl update-channels
rm -rf /tmp/pear ~/.pearrc
php --version
```

## 9. 复制并设置 docker-php 扩展脚本权限

```bash
cp /opt/src/docker-php-ext-* /opt/src/docker-php-entrypoint /usr/local/bin/
chmod +x /usr/local/bin/docker-php-ext-* /usr/local/bin/docker-php-entrypoint
```

## 10. 启用扩展

```bash
docker-php-ext-enable opcache
docker-php-ext-enable sodium
```