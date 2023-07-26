PROD_REG?=yinyue123/ddos-firewal
IMG_TAG?=v0.1
PROD_IMG?=${PROD_REG}:${IMG_TAG}

all: push

push:
	docker build -f Dockerfile . -t $(PROD_IMG)
	docker push ${PROD_IMG}
