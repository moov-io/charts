
all:
	echo "moov-io/charts"

.PHONY: lint test
lint:
	find ./charts -maxdepth 1 -mindepth 1 -type d | xargs -n1 helm lint

test: lint
