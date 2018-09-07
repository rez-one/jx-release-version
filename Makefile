NAME := jx-release-version
ORG := rez-one
ROOT_PACKAGE := main.go
DOCKER_ORG := clank
VERSION=$(shell docker run --rm -v${PWD}:/git -eGITHUB_AUTH_TOKEN=${GITHUB_AUTH_TOKEN} clank/jx-release-version --gh-owner=${ORG} --gh-repository=${NAME})

BUILD_DIR ?= ./bin

BUILDFLAGS := -a -installsuffix cgo -ldflags="-w -s"

.PHONY: docker
docker: check-env
	docker build -t "$(DOCKER_ORG)/$(NAME):$(VERSION)" .

.PHONY: snapshot
snapshot: clean docker
	mkdir -p $(BUILD_DIR)
	docker save --output "$(BUILD_DIR)/$(DOCKER_ORG)-$(NAME)-$(VERSION)" "$(DOCKER_ORG)/$(NAME):$(VERSION)" 

.PHONY: release
release: docker
	docker push "$(DOCKER_ORG)/$(NAME):$(VERSION)"
	docker tag "$(DOCKER_ORG)/$(NAME):$(VERSION)" "$(DOCKER_ORG)/$(NAME):latest"
	docker push "$(DOCKER_ORG)/$(NAME):latest"
	git tag -a v$(VERSION) -m "Release Version $(VERSION)"
	git remote set-url origin git@github.com:$(ORG)/$(NAME).git
	git push origin v$(VERSION)

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY: check-env
check-env:
ifndef GITHUB_AUTH_TOKEN
$(error GITHUB_AUTH_TOKEN is not defined)
endif
