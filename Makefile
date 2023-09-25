.SUFFIXES:
.DELETE_ON_ERROR:

MAKEFLAGS += --no-builtin-rules

SHELL := /bin/sh -e -c

CURRENT_UID := $(shell id -u)
CURRENT_GID := $(shell id -g)

DOCKER := docker

VERSION := $(shell echo '$(GITHUB_REF_NAME)' | sed -r -e 's#[^-.a-zA-Z0-9]+#-#g')

NFPM_CONTAINER_IMAGE := docker.io/goreleaser/nfpm:latest
NFPM_COMMAND := \
	$(DOCKER) run --rm --user $(CURRENT_UID):$(CURRENT_GID) \
	--volume '$(PWD):/build:rw' -w /build \
	--env 'STSETUP_VERSION=$(VERSION)' \
	$(NFPM_CONTAINER_IMAGE)

PACKAGERS := apk deb

TARGET_DIR := dist

all: package-all

package-all: $(foreach i,$(PACKAGERS),package-$(i)) ;

.PHONY: target.dir
target.dir:
	test -d $(TARGET_DIR) || mkdir $(TARGET_DIR)

.PHONY: package-%
package-%: | target.dir test
	$(NFPM_COMMAND) package --config nfpm.yaml --packager $* --target $(TARGET_DIR)/

.PHONY: clean
clean:
	rm -rf $(TARGET_DIR)

.PHONY: test
test:
	./stsetup -h >/dev/null
	./find_unused_port >/dev/null
	./find_unused_port --help >/dev/null
