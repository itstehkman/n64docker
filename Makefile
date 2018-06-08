.PHONY: build run run-client mupen-config client-config stop-client stop rm rm-client

BASH := $(shell which bash)
SHELL := $(BASH)
CLIENT_PORT := $(shell expr 5900 + $(PLAYER_NUM))
NOVNCPORT := $(shell expr 8000 + $(PLAYER_NUM))

include .env

.network:
	docker network create ${NETWORK_NAME}
	touch .network

mupen-config:
	ruby util/gentranslation.rb > config/keysym-translation.json
	ruby util/genmupencfg.rb > config/mupen64plus.cfg

build: mupen-config
	docker build -t $(SERVER_IMAGE_NAME) . -f Dockerfile.server
	docker build -t $(CLIENT_IMAGE_NAME) . -f Dockerfile.client
	docker build -t $(NOVNC_IMAGE_NAME) . -f Dockerfile.novnc

run-all:
	$(MAKE) run
	export PLAYER_NUM=1 && export && $(MAKE) run-proxy
	export PLAYER_NUM=1 && export && $(MAKE) run-novnc

run: .network
	docker run -d -p '5900:5900' --net $(NETWORK_NAME) --name $(SERVER_CONTAINER_NAME) $(SERVER_IMAGE_NAME)

run-proxy: .network
	docker run -d -p $(CLIENT_PORT):5900 --net $(NETWORK_NAME) --privileged -e "SERVER" -e "PLAYER_NUM" --name $(CLIENT_CONTAINER_NAME)-proxy-$(PLAYER_NUM) $(CLIENT_IMAGE_NAME)

run-proxies: .network
	export PLAYER_NUM=1 && export CLIENT_PORT=5901 && export && $(MAKE) run-proxy
	export PLAYER_NUM=2 && export CLIENT_PORT=5902 && export && $(MAKE) run-proxy
	export PLAYER_NUM=3 && export CLIENT_PORT=5903 && export && $(MAKE) run-proxy
	export PLAYER_NUM=4 && export CLIENT_PORT=5904 && export && $(MAKE) run-proxy

run-novnc: .network
	docker run -it -p 6080:6080 --net $(NETWORK_NAME) -e "SERVER=$(CLIENT_CONTAINER_NAME)-proxy-$(PLAYER_NUM)" -e PORT=5900 $(NOVNC_IMAGE_NAME)

run-bash:
	docker run -it -p 5901:5900 --net $(NETWORK_NAME) --name $(CLIENT_CONTAINER_NAME)-1 --privileged -e "SERVER" -e "PLAYER_NUM" $(CLIENT_IMAGE_NAME) bash

stop-client:
	docker kill $(CLIENT_CONTAINER_NAME)-1 $(CLIENT_CONTAINER_NAME)-2 $(CLIENT_CONTAINER_NAME)-3 $(CLIENT_CONTAINER_NAME)-4
	docker rm $(CLIENT_CONTAINER_NAME)-1 $(CLIENT_CONTAINER_NAME)-2 $(CLIENT_CONTAINER_NAME)-3 $(CLIENT_CONTAINER_NAME)-4

rm:
	docker rm `docker ps -a | grep $(IMAGE_NAME_BASE) | awk '{print $$1}'`

stop:
	docker kill `docker ps -a | grep $(IMAGE_NAME_BASE) | awk '{print $$1}'`
	$(MAKE) rm

tag:
	docker tag $(SERVER_IMAGE_NAME) itstehkman/$(SERVER_IMAGE_NAME)
	docker tag $(CLIENT_IMAGE_NAME) itstehkman/$(CLIENT_IMAGE_NAME)

push:
	$(MAKE) tag
	docker push itstehkman/$(SERVER_IMAGE_NAME)
	docker push itstehkman/$(CLIENT_IMAGE_NAME)
