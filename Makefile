OWNER      ?= $(shell whoami)
IMAGE      := $(OWNER)/$(shell basename "$$( dirname "$(PWD)")")-$(shell basename "$(PWD)")
BASE_IMAGE ?= steigr/tomcat:centos
TAGS       := $(foreach tag,$(sort $(wildcard */)),$(patsubst %,bitbucket-base-%,$(tag)))

all: build

build: $(TAGS)

bitbucket-base-%:
	$(eval version := $(shell echo "$@" | sed -e 's/bitbucket-base-//'))
	cat "$(version)/Dockerfile" \
| sed -e 's@%BASE_IMAGE%@$(BASE_IMAGE)@g' \
> Dockerfile.tmp
	docker build --tag "$(IMAGE):$(version)" --file Dockerfile.tmp . \
&& rm Dockerfile.tmp
	docker tag --force "$(IMAGE):$(version)" "$(IMAGE):latest" 

push: build
	$(foreach image,$(shell docker images | grep -e "^$(IMAGE)\s" | awk '{print $$1 ":" $$2}'),docker push $(image);)