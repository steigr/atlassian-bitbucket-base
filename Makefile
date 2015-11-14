OWNER      ?= $(shell whoami)
IMAGE      := $(OWNER)/$(shell basename "$$( dirname "$(PWD)")")-$(shell basename "$(PWD)")
BASE_IMAGE ?= steigr/tomcat:centos
TAGS       := $(foreach tag,$(sort $(wildcard */)),$(patsubst %,bitbucket-base-%,$(tag)))
LFS_TEMP   := $(shell mktemp -d)
LFS_URL    := https://github.com/github/git-lfs/releases/download/v1.0.2/git-lfs-linux-amd64-1.0.2.tar.gz

all: build

build: lfs $(TAGS)

bitbucket-base-%:
	$(eval version := $(shell echo "$@" | sed -e 's/bitbucket-base-//'))
	cat "$(version)/Dockerfile" \
| sed -e 's@%BASE_IMAGE%@$(BASE_IMAGE)@g' \
> Dockerfile.tmp
	docker build --tag "$(IMAGE):$(version)" --file Dockerfile.tmp . \
&& rm Dockerfile.tmp
	docker tag --force "$(IMAGE):$(version)" "$(IMAGE):latest" 

info: build
	$(foreach image,$(shell docker images | grep -e "^$(IMAGE)\s" | awk '{print $$1 ":" $$2}'),docker inspect $(image);)

push: build
	$(foreach image,$(shell docker images | grep -e "^$(IMAGE)\s" | awk '{print $$1 ":" $$2}'),docker push $(image);)

clean:
	$(foreach image,$(shell docker images | grep -e "^$(IMAGE)\s" | awk '{print $$1 ":" $$2}'),docker rmi --force $(image);)

lfs-install:
	curl -L "$(LFS_URL)" | tar -z -x -C "$(LFS_TEMP)" --strip-components 1
	PATH="$$PATH:$(LFS_TEMP)" git lfs pull

lfs-check:
	test -x "$$(command -v git-lfs)"

lfs:
	$(MAKE) lfs-check \
	|| $(MAKE) lfs-install
	$(eval PATH := "$(PATH):$(LFS_TEMP)")
