# Copyright (c) 2020, NVIDIA CORPORATION.  All rights reserved.
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

DOC     = /usr/share/doc/cuda
VAR     = /var/cuda

RELEASE ?= r32.4
TAG     ?= r32.4.3
CUDA    ?= 10.2
L4T_CUDA_REGISTRY   ?= "nvcr.io/nvidian/nvidia-l4t-cuda"
L4T_BASE_REGISTRY   ?= "nvcr.io/nvidian/nvidia-l4t-base"

include $(CURDIR)/common.mk

all: image

image:
	mkdir -p ${CURDIR}/dst
	podman build $(DOCKER_BINFMT_MISC) -t $(L4T_CUDA_REGISTRY):$(TAG) \
		--build-arg "RELEASE=$(RELEASE)" --build-arg "CUDA=$(CUDA)" \
		-f ./Dockerfile.cuda ./
	podman run -t $(DOCKER_BINFMT_MISC) -v $(CURDIR)/dst:/dst $(L4T_CUDA_REGISTRY):$(TAG) sh -c 'cp -r /usr/local/cuda/* /dst'
	podman build $(DOCKER_BINFMT_MISC) -t $(L4T_BASE_REGISTRY):$(TAG) \
		--build-arg "RELEASE=$(RELEASE)" --build-arg "CUDA=$(CUDA)" \
		-v $(CURDIR)/dst:/dst \
		-f ./Dockerfile.l4t .
	podman rm `podman ps -a | grep nvcr.io/nvidian/nvidia-l4t-cuda:r32.4.3 | head -n1 | awk '{print $$1;}'`
	podman rmi  `podman images | grep nvcr.io/nvidian/nvidia-l4t-cuda  | head -n1 | awk '{print $$3;}'`

push:
	podman push nvcr.io/nvidian/nvidia-l4t-base:$(RELEASE)
