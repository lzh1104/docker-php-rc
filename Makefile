
DOCKERCMD=docker
DOCKERBUILD=$(DOCKERCMD) build
DOCKERPUSH=$(DOCKERCMD) push
IMAGES_NAME=lzh1104/php-rc

all: build
build:
	echo "5.6-fpm, 7.0-fpm, 7.4-fpm"
	
test:
	docker run -it --rm $(IMAGES_NAME):7.4-fpm /bin/ash

5.6-fpm:
	$(DOCKERBUILD) -f Dockerfile.5.6-fpm -t $(IMAGES_NAME):5.6-fpm .
	$(DOCKERPUSH) $(IMAGES_NAME):5.6-fpm

7.0-fpm:
	$(DOCKERBUILD) -f Dockerfile.fpm -t $(IMAGES_NAME):7.0-fpm .
	$(DOCKERPUSH) $(IMAGES_NAME):7.0-fpm

7.4-fpm:
	$(DOCKERBUILD) -f Dockerfile.7.4-fpm -t $(IMAGES_NAME):7.4-fpm .
	$(DOCKERPUSH) $(IMAGES_NAME):7.4-fpm