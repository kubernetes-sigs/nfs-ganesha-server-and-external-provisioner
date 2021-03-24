# Copyright 2019 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CMDS=nfs-provisioner
all: build

include release-tools/build.make

ifeq ($(REGISTRY),)
	REGISTRY = gcr.io/k8s-staging-sig-storage/
endif

ifeq ($(VERSION),)
	VERSION = latest
endif

IMAGE_ARM = $(REGISTRY)nfs-provisioner-arm:$(VERSION)
MUTABLE_IMAGE_ARM = $(REGISTRY)nfs-provisioner-arm:latest

build-docker-arm:
	GOOS=linux GOARCH=arm GOARM=7 go build -o deploy/docker/arm/nfs-provisioner ./cmd/nfs-provisioner
.PHONY: build-docker-arm

container-arm: build-docker-arm quick-container-arm
.PHONY: container-arm

quick-container-arm:
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker build -t $(MUTABLE_IMAGE_ARM) deploy/docker/arm
	docker tag $(MUTABLE_IMAGE_ARM) $(IMAGE_ARM)
.PHONY: quick-container-arm

push-arm: container-arm
	docker push $(IMAGE_ARM)
	docker push $(MUTABLE_IMAGE_ARM)
.PHONY: push-arm

clean-binary:
	rm -f nfs-provisioner
	rm -f bin/nfs-provisioner
	rm -f deploy/docker/nfs-provisioner
	rm -f deploy/docker/x86_64/nfs-provisioner
	rm -f deploy/docker/arm/nfs-provisioner
.PHONY: clean-binary

