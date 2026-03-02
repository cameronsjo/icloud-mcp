.DEFAULT_GOAL := help

## Development
.PHONY: build
# Build the binary
build:
	go build -o bin/ ./...

.PHONY: run
# Run the MCP server
run: build
	./bin/icloud-mcp

## Quality
.PHONY: check
# Run linting
check:
	golangci-lint run

.PHONY: test
# Run test suite
test:
	go test ./...

.PHONY: test-cover
# Run tests with coverage
test-cover:
	go test -coverprofile=coverage.out ./... && go tool cover -html=coverage.out

## Help
.PHONY: help
# Show available targets
help:
	@grep -E '^[a-zA-Z_-]+:.*?#' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?# "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
