########################################################
#                       Makefile                       #
########################################################

.DEFAULT_GOAL := all
.PHONY: all setup build run lint test format generate tidy

########################################################
#                         Setup                        #
########################################################

TAG_COMMIT := $(shell git rev-list --abbrev-commit --tags --max-count=1)
TAG := $(shell git describe --abbrev=0 --tags ${TAG_COMMIT} 2>/dev/null || true)
COMMIT := $(shell git rev-parse --short HEAD)
DATE := $(shell git log -1 --format=%cd --date=format:"%Y%m%d")
VERSION := $(TAG:v%=%)
ifneq ($(COMMIT), $(TAG_COMMIT))
    VERSION := $(VERSION)-next-$(COMMIT)-$(DATE)
endif
ifneq ($(shell git status --porcelain),)
    VERSION := $(VERSION)-dirty
endif

########################################################
#                       Building                       #
########################################################

build:
	@echo "Building all packages"
	@go build ./...

run-%:
	@echo "Running $* example"
	@go run ./examples/$*/main.go start

lint:
	@echo "Running linting"
	@go run github.com/golangci/golangci-lint/cmd/golangci-lint run

test:
	@echo "Running tests"
	@go test -v ./...

format:
	@echo "Formatting code"
	@go run github.com/golangci/golangci-lint/cmd/golangci-lint run --fix

generate:
	@echo "Generating code"
	@go generate ./...

tidy:
	@echo "Tidying modules"
	@go mod tidy

all: setup build

setup:
	@echo "Setting up project"
	@echo "Version: $(VERSION)"
