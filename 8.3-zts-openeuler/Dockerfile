#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM openeuler/openeuler:24.03-lts

RUN sed -i 's/repo.openeuler.org/mirrors.aliyun.com\/openeuler/g' /etc/yum.repos.d/openEuler.repo && dnf makecache

# prevent OpenEuler's PHP packages from being installed
RUN set -eux; \
	dnf config-manager --set-enabled crb || :

# dependencies required for running "phpize"
# (see persistent deps below)
ENV PHPIZE_DEPS \
		autoconf \
		automake \
		make \
		file \
		g++ \
		gcc \
		glibc-devel \
		pkgconfig \
		shadow-utils \
		diffutils

# persistent / runtime deps
RUN set -eux; \
	dnf install -y \
		$PHPIZE_DEPS \
		curl

ENV PHP_INI_DIR /usr/local/etc/php
RUN set -eux; \
	groupadd -g 82 www-data; \
	useradd -u 82 -g www-data -r -s /sbin/nologin -M www-data; \
	mkdir -p "$PHP_INI_DIR/conf.d"; \
# allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
	[ ! -d /var/www/html ]; \
	mkdir -p /var/www/html; \
	chown www-data:www-data /var/www/html; \
	chmod 1777 /var/www/html

# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# https://github.com/docker-library/php/issues/272
# -D_LARGEFILE_SOURCE and -D_FILE_OFFSET_BITS=64 (https://www.php.net/manual/en/intro.filesystem.php)
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -pie"

ENV GPG_KEYS 1198C0117593497A5EC5C199286AF1F9897469DC C28D937575603EB4ABB725861C0779DC5C0A9DE4 AFD8691FDAEDF03BDF6E460563F15A9B715376CA

ENV PHP_VERSION 8.3.29
ENV PHP_URL="https://www.php.net/distributions/php-8.3.29.tar.xz" PHP_ASC_URL="https://www.php.net/distributions/php-8.3.29.tar.xz.asc"
ENV PHP_SHA256="f7950ca034b15a78f5de9f1b22f4d9bad1dd497114d175cb1672a4ca78077af5"

RUN set -eux; \
	\
	dnf install -y gnupg; \
	\
	mkdir -p /usr/src; \
	cd /usr/src; \
	\
	curl -fsSL -o php.tar.xz "$PHP_URL"; \
	\
	if [ -n "$PHP_SHA256" ]; then \
		echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
	fi; \
	\
	curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL"; \
	export GNUPGHOME="$(mktemp -d)"; \
	for key in $GPG_KEYS; do \
		gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
	done; \
	gpg --batch --verify php.tar.xz.asc php.tar.xz; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME"; \
	\
	dnf remove -y $(rpm -qa | grep -v '^gpg\|^shadow\|^ca-certificates') || :
	# Handle package removal for build dependencies

RUN set -eux; \
	\
	cd /usr/src; \
	curl -fsSL -o libiconv-1.18.tar.gz https://mirrors.aliyun.com/gnu/libiconv/libiconv-1.18.tar.gz; \
	tar -zxvf libiconv-1.18.tar.gz; \
	cd libiconv-1.18; \
	./configure --prefix=/usr; \
	make; \
	make install; \
	cd ..; \
	rm -rf libiconv-1.18; \
	rm -rf libiconv-1.18.tar.gz

COPY docker-php-source /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-php-source

RUN set -eux; \
	\
	dnf install -y \
		libargon2-devel \
		libcurl-devel \
		readline-devel \
		oniguruma-devel \
		libsodium-devel \
		sqlite-devel \
		openssl-devel \
		libxml2-devel \
		zlib-devel \
	; \
	\
	export \
		CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS" \
# https://github.com/php/php-src/blob/d6299206dd828382753453befd1b915491b741c6/configure.ac#L1496-L1511
		PHP_BUILD_PROVIDER='https://github.com/docker-library/php' \
		PHP_UNAME='Linux - Docker' \
	; \
	docker-php-source extract; \
	cd /usr/src/php; \
	gnuArch="$(uname -m)"; \
	libDir="lib"; \
	if [ "$(uname -m)" = "aarch64" ]; then \
		gnuArch="aarch64-linux-gnu"; \
		libDir="lib64"; \
	elif [ "$(uname -m)" = "x86_64" ]; then \
		gnuArch="x86_64-linux-gnu"; \
		libDir="lib64"; \
	fi; \
# Create symlink if needed
	if [ ! -d /usr/include/curl ] && [ -d "/usr/include/$libDir" ]; then \
		ln -sT "/usr/include/$libDir/curl" /usr/local/include/curl || :; \
	fi; \
	./configure \
		--build="$gnuArch" \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		\
# make sure invalid --configure-flags are fatal errors instead of just warnings
		--enable-option-checking=fatal \
		\
# https://github.com/docker-library/php/issues/439
		--with-mhash \
		\
# https://github.com/docker-library/php/issues/822
		--with-pic \
		\
# --enable-mbstring is included here because otherwise there's no way to get pecl to use it properly (see https://github.com/docker-library/php/issues/195)
		--enable-mbstring \
# --enable-mysqlnd is included here because it's harder to compile after the fact than extensions are (since it's a plugin for several extensions, not an extension in itself)
		--enable-mysqlnd \
# https://wiki.php.net/rfc/argon2_password_hash
		--with-password-argon2 \
# https://wiki.php.net/rfc/libsodium
		--with-sodium=shared \
# always build against system sqlite3 (https://github.com/php/php-src/commit/6083a387a81dbbd66d6316a3a12a63f06d5f7109)
		--with-pdo-sqlite=/usr \
		--with-sqlite3=/usr \
		\
		--with-curl \
		--with-iconv=/usr/bin \
		--with-openssl \
		--with-readline \
		--with-zlib \
		\
# https://github.com/docker-library/php/pull/1259
		--enable-phpdbg \
		--enable-phpdbg-readline \
		\
# in PHP 7.4+, the pecl/pear installers are officially deprecated (requiring an explicit "--with-pear")
		--with-pear \
		\
		--with-libdir="$libDir" \
		\
# https://github.com/docker-library/php/pull/939#issuecomment-730501748
		--enable-embed \
		\
		--enable-zts \
# https://externals.io/message/118859
		--disable-zend-signals \
	; \
	make -j "$(nproc)"; \
	find -type f -name '*.a' -delete; \
	make install; \
	find \
		/usr/local \
		-type f \
		-perm '/0111' \
		-exec sh -euxc ' \
			strip --strip-all "$@" || : \
		' -- '{}' + \
	; \
	make clean; \
	\
# https://github.com/docker-library/php/issues/692 (copy default example "php.ini" files somewhere easily discoverable)
	cp -v php.ini-* "$PHP_INI_DIR/"; \
	\
	cd /; \
	docker-php-source delete; \
	\
	dnf remove -y $(rpm -qa | grep -v '^gpg\|^curl\|^xz\|^ca-certificates\|^libargon2\|^libcurl\|^readline\|^libsodium\|^sqlite\|^openssl\|^libxml2\|^zlib') || : ; \
	dnf clean all; \
	\
# update pecl channel definitions https://github.com/docker-library/php/issues/443
	pecl update-channels; \
	rm -rf /tmp/pear ~/.pearrc; \
	\
# smoke test
	php --version

COPY docker-php-ext-* docker-php-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-php-ext-* /usr/local/bin/docker-php-entrypoint

# enable OPcache by default (https://wiki.php.net/rfc/make_opcache_required)
RUN docker-php-ext-enable opcache

# sodium was built as a shared module (so that it can be replaced later if so desired), so let's enable it too (https://github.com/docker-library/php/issues/598)
RUN docker-php-ext-enable sodium

ENTRYPOINT ["docker-php-entrypoint"]
CMD ["php", "-a"]
