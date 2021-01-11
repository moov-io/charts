CHART_DIRS=$(shell find ./stable -maxdepth 1 -mindepth 1 -type d)
PLATFORM=$(shell uname -s | tr '[:upper:]' '[:lower:]')

all: test

.PHONY: setup lint render kubeval-setup integration

setup:
	@mkdir -p ./bin/
	curl -L https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

lint:
	@echo $(CHART_DIRS) | xargs -n1 helm lint

render: kubeval-setup
	for dir in $(CHART_DIRS); do \
		name=$$(basename "$$dir"); \
		tmp=$(shell mktemp -d); \
		helm template "$$name" stable/"$$name"/ --output-dir "$$tmp"; \
		find "$$tmp" -type f -name "*.yaml" | xargs -n1 cat; \
		echo "---"; \
		find "$$tmp" -type f -name "*.yaml" | xargs -n1 ./bin/kubeval --strict -v 1.16.4; \
		rm -rf "$$tmp"; \
	done

kubeval-setup:
	@mkdir -p ./bin/
	wget -O kubeval.tar.gz https://github.com/instrumenta/kubeval/releases/download/0.15.0/kubeval-$(PLATFORM)-amd64.tar.gz
	tar -xf kubeval.tar.gz kubeval
	mv kubeval ./bin/kubeval
	chmod +x ./bin/kubeval
	rm kubeval*.tar.gz

test: lint render integration

clean: integration-cleanup

integration-install:
	@mkdir -p ./bin/
	wget -O ./bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(shell curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/$(PLATFORM)/amd64/kubectl
	wget -O ./bin/kind https://github.com/kubernetes-sigs/kind/releases/download/v0.9.0/kind-$(PLATFORM)-amd64
	chmod +x ./bin/kubectl ./bin/kind

integration-setup: setup integration-install
	./bin/kind create cluster --wait 2m
	./bin/kubectl create namespace apps

integration-cleanup:
	./bin/kubectl get pods -n apps
	for dir in $(CHART_DIRS); do \
		name=$$(basename "$$dir"); \
		helm uninstall "$$name"; \
	done

integration-destroy: integration-cleanup
	./bin/kind delete cluster

integration:
	./bin/kubectl cluster-info
	for dir in $(CHART_DIRS); do \
		name=$$(basename "$$dir"); \
		helm install "$$name" ./stable/"$$name" --wait --debug; \
		helm test "$$name" --timeout=30s; \
	done
