CGO_ENABLED=0
GOOS=linux
GOARCH=amd64
BIN="bin"
APP="movies-service"
SRC=$(shell find . -name "*.go")
SERVICE_PREFIX='movies'
SERVICE_NAME='movies-service'
DOCKER_USERNAME='hamzabll5858'

ifeq (, $(shell which go))
$(warning "could not find go in $(PATH), Install golang")
endif

.PHONY: all deploy-k3d delete-k3d build-image push-image deploy-server delete-server deploy-ingress-controller delete-ingress-controller deploy-monitoring delete-monitoring build install_deps clean

default: all

all: build

deploy-k3d:
	curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v5.4.1 bash
	k3d registry create $(SERVICE_PREFIX)-registry.localhost --port 5000
	k3d cluster create --wait --config ./config/movies-cluster-config.yaml \
    	--registry-use k3d-$(SERVICE_PREFIX)-registry.localhost:5000 \
    	--k3s-arg="--disable=traefik@server:0" \
        --k3s-arg="--tls-san=127.0.0.1@server:0"
	sleep 300
	echo 'Stage deploy-k3d Successfull!'

delete-k3d:
	k3d cluster delete $(SERVICE_PREFIX)-cluster
	k3d registry delete $(SERVICE_PREFIX)-registry.localhost

deploy-ingress-controller:
	kubectl create ns $(SERVICE_PREFIX)-ingress-controller || sleep 1
	helm upgrade --install $(SERVICE_PREFIX)-ingress-controller -n $(SERVICE_PREFIX)-ingress-controller ./ops/helm/ingress-controller
	echo 'Stage deploy-ingress-controller Successfull!'

delete-ingress-controller:
	kubectl -n $(SERVICE_PREFIX)-ingress-controller delete secret nginx-server-certs
	helm delete $(SERVICE_PREFIX)-ingress-controller -n $(SERVICE_PREFIX)-ingress-controller
	kubectl delete ns $(SERVICE_PREFIX)-ingress-controller

build-image:
	docker build -t $(SERVICE_NAME):latest .
	docker tag $(SERVICE_NAME):latest $(DOCKER_USERNAME)/$(SERVICE_NAME):latest
	echo 'Stage build Successfull!'

push-image:
	docker push $(DOCKER_USERNAME)/$(SERVICE_NAME):latest

deploy-server:
	kubectl create ns $(SERVICE_NAME) || sleep 1
	helm upgrade --install  $(SERVICE_NAME) -n $(SERVICE_NAME) ./ops/helm/$(SERVICE_NAME)
	echo 'Stage $(SERVICE_NAME) deploy-server Successfull!'

delete-server:
	helm delete $(SERVICE_NAME)  -n $(SERVICE_NAME)
	kubectl delete ns $(SERVICE_NAME)
	echo 'Stage $(SERVICE_NAME) delete-server Successfull!'

deploy-monitoring:
	kubectl create ns movies-monitoring || sleep 1
	helm upgrade --install movies-monitoring -n movies-monitoring ./ops/helm/kube-prometheus-stack
	echo 'Stage deploy-monitoring Successfull!'

delete-monitoring:
	helm delete movies-monitoring -n movies-monitoring
	kubectl delete ns movies-monitoring

build: install_deps
	go \
        build -a -installsuffix cgo -v \
        -o $(BIN)/$(APP) . \
        ;

install_deps:
	$(info ******************** downloading dependencies ********************)
	go get -v ./...

clean: delete-k3d
	rm -rf $(BIN)/$(APP)