CHART_DIRS=$(shell find ./charts -maxdepth 1 -mindepth 1 -type d)
PLATFORM=$(shell uname -s | tr '[:upper:]' '[:lower:]')

all:
	echo "moov-io/charts"

.PHONY: lint rendertest
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
	done

kubeval-setup:
	wget -nc https://github.com/instrumenta/kubeval/releases/download/0.14.0/kubeval-$(PLATFORM)-amd64.tar.gz
	tar -xf kubeval-$(PLATFORM)-amd64.tar.gz kubeval && chmod +x ./kubeval

test: lint render
