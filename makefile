
all:
	echo "moov-io/charts"

.PHONY: lint test
lint:
	find ./charts -type d -maxdepth 1 -mindepth 1 | xargs -n1 helm lint

test: lint
