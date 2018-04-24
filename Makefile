.PHONY: build run run-client mupen-config client-config stop-client stop rm rm-client

BASH := $(shell which bash)
SHELL := $(BASH)

include .env

.network:
	docker network create ${NETWORK_NAME}
	echo " " > .network

mupen-config:
	ruby util/gentranslation.rb > config/keysym-translation.json
	ruby util/genmupencfg.rb > config/mupen64plus.cfg

build: mupen-config
	docker build -t $(SERVER_IMAGE_NAME) . -f Dockerfile.server
	docker build -t $(CLIENT_IMAGE_NAME) . -f Dockerfile.client

run: .network mupen-config
	docker run -it -p '5900:5900' --net $(NETWORK_NAME) --name $(SERVER_CONTAINER_NAME) --privileged $(SERVER_IMAGE_NAME)

run-client: .network
	docker run -it -p '5901:5900' --net $(NETWORK_NAME) --name $(CLIENT_CONTAINER_NAME) --privileged -e "SERVER" -e "PLAYER_NUM" $(CLIENT_IMAGE_NAME)

run-bash:
	docker run -it -p '5901:5900' --net $(NETWORK_NAME) --name $(CLIENT_CONTAINER_NAME) --privileged -e "SERVER" -e "PLAYER_NUM" $(CLIENT_IMAGE_NAME) bash

rm-client:
	docker rm $(CLIENT_CONTAINER_NAME)

rm:
	docker rm $(CLIENT_CONTAINER_NAME) $(SERVER_CONTAINER_NAME)

stop:
	docker kill $(CLIENT_CONTAINER_NAME) $(SERVER_CONTAINER_NAME)
	$(MAKE) rm
