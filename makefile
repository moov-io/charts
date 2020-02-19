CHART_DIRS=$(shell find ./charts -maxdepth 1 -mindepth 1 -type d)
PLATFORM=$(shell uname -s | tr '[:upper:]' '[:lower:]')

all: test

.PHONY: setup lint render kubeval-setup integration

setup:
	curl -L https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

lint:
	@echo $(CHART_DIRS) | xargs -n1 helm lint

render: kubeval-setup
	for dir in $(CHART_DIRS); do \
		name=$$(basename "$$dir"); \
		tmp=$(shell mktemp -d); \
		helm template "$$name" charts/"$$name"/ --output-dir "$$tmp"; \
		find "$$tmp" -type f -name "*.yaml" | xargs -n1 cat; \
		echo "---"; \
		find "$$tmp" -type f -name "*.yaml" | xargs -n1 ./kubeval --strict -v 1.14.7; \
		rm -rf "$$tmp"; \
	done

kubeval-setup:
	wget -nc https://github.com/instrumenta/kubeval/releases/download/0.14.0/kubeval-$(PLATFORM)-amd64.tar.gz
	tar -xf kubeval-$(PLATFORM)-amd64.tar.gz kubeval && chmod +x ./kubeval

test: lint render integration

clean: integration-cleanup

integration-install:
	@mkdir -p ./bin/
	wget -nc https://storage.googleapis.com/kubernetes-release/release/$(shell curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/$(PLATFORM)/amd64/kubectl
	wget -nc https://github.com/kubernetes-sigs/kind/releases/download/v0.5.1/kind-$(PLATFORM)-amd64
	ln -f -s ./kind-$(PLATFORM)-amd64 ./kind
	chmod +x ./kubectl ./kind

integration-setup: setup integration-install
	./kind create cluster --wait 2m

integration-cleanup:
	KUBECONFIG=$(shell ./kind get kubeconfig-path) ./kubectl get pods
	for dir in $(CHART_DIRS); do \
		name=$$(basename "$$dir"); \
		KUBECONFIG=$(shell ./kind get kubeconfig-path) \
		helm uninstall "$$name" && \
		./kubectl delete pods "$$name"-test-connection; \
	done

integration-destroy: integration-cleanup
	./kind delete cluster

integration:
	KUBECONFIG=$(shell ./kind get kubeconfig-path) ./kubectl cluster-info
	for dir in $(CHART_DIRS); do \
		name=$$(basename "$$dir"); \
		KUBECONFIG=$(shell ./kind get kubeconfig-path) helm install "$$name" ./charts/"$$name" --wait --debug; \
		KUBECONFIG=$(shell ./kind get kubeconfig-path) helm test "$$name" --timeout=30s; \
	done
