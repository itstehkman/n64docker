.PHONY: setup build run run-client

BASH := $(shell which bash)
SHELL := $(BASH)

include .env

.network:
	docker network create ${NETWORK_NAME}
	echo " " > .network

build:
	docker build -t $(SERVER_IMAGE_NAME) . -f Dockerfile.server
	docker build -t $(CLIENT_IMAGE_NAME) . -f Dockerfile.client

run: .network
	docker run -it -p '5900:5900' --net $(NETWORK_NAME) --name $(SERVER_CONTAINER_NAME) --privileged $(SERVER_IMAGE_NAME)

run-client: .network
	docker run -it -p '5901:5900' --net $(NETWORK_NAME) --name $(CLIENT_CONTAINER_NAME) --privileged -e "SERVER=$(SERVER_CONTAINER_NAME)" $(CLIENT_IMAGE_NAME)
