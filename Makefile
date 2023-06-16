TOP := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

ARCH ?= $(shell uname -m)
HOST_ARCH ?= $(shell uname -m)
UPSTREAM_SOURCE_FALLBACK ?= false

VERSION := $(shell cat $(TOP)VERSION)
SHORT_SHA := $(shell git rev-parse --short=8 HEAD)

SDK_TAG := bottlerocket/sdk-$(ARCH):$(VERSION)-$(SHORT_SHA)-$(HOST_ARCH)
TOOLCHAIN_TAG := bottlerocket/toolchain-$(ARCH):$(VERSION)-$(SHORT_SHA)-$(HOST_ARCH)

all: sdk toolchain

sdk:
	@DOCKER_BUILDKIT=1 docker build . \
		--tag $(SDK_TAG) \
		--target sdk-golden \
		--build-arg ARCH=$(ARCH) \
		--build-arg HOST_ARCH=$(HOST_ARCH) \
		--build-arg UPSTREAM_SOURCE_FALLBACK=$(UPSTREAM_SOURCE_FALLBACK)

toolchain:
	@DOCKER_BUILDKIT=1 docker build . \
		--tag $(TOOLCHAIN_TAG) \
		--target toolchain-golden \
		--build-arg ARCH=$(ARCH) \
		--build-arg HOST_ARCH=$(HOST_ARCH) \
		--build-arg UPSTREAM_SOURCE_FALLBACK=$(UPSTREAM_SOURCE_FALLBACK)

publish:
	@test $${REGISTRY?not set!}
	@test $${SDK_NAME?not set!}
	$(TOP)publish-sdk --registry=$(REGISTRY) --sdk-name=$(SDK_NAME) --version=$(VERSION) --short-sha=$(SHORT_SHA)

.PHONY: all sdk toolchain publish
