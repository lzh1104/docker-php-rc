
DOCKERCMD=docker
DOCKERBUILD=$(DOCKERCMD) buildx build
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

8.0-fpm:
	$(DOCKERBUILD) -f Dockerfile.8.0-fpm -t $(IMAGES_NAME):8.0-fpm .
	$(DOCKERPUSH) $(IMAGES_NAME):8.0-fpm
	
8.1-fpm:
	$(DOCKERBUILD) -f Dockerfile.8.1-fpm -t $(IMAGES_NAME):8.1-fpm .
	$(DOCKERPUSH) $(IMAGES_NAME):8.1-fpm
	
8.2-fpm:
	$(DOCKERBUILD) --build-arg SWOOLE_VERSION=5.0.1 --build-arg SWOW_VERSION=1.1.0 --build-arg USE_SWOW=swow -f Dockerfile.8.2-fpm -t $(IMAGES_NAME):8.2-fpm .
	$(DOCKERPUSH) $(IMAGES_NAME):8.2-fpm
	
8.3-zts:
	$(DOCKERBUILD) -f Dockerfile.8.3-zts -t $(IMAGES_NAME):8.3-zts .
	# $(DOCKERPUSH) $(IMAGES_NAME):8.3-zts