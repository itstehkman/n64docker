IMAGE_NAME=mupen64plus-x11vnc

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run -it -p '5900:5900' $(IMAGE_NAME)
