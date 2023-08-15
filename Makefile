PROD_REG?=yinyue123/ddos-firewal
IMG_TAG?=v2.4
PROD_IMG?=${PROD_REG}:${IMG_TAG}
export DOCKER_HOST?=tcp://192.168.10.1:2375

all: push

push:
	docker build -f Dockerfile . -t $(PROD_IMG)
	docker push ${PROD_IMG}
