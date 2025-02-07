#!/bin/bash
set -x

PROG=rke2
REGISTRY=docker.io
REPO=${REPO:-rancher}
K3S_PKG=github.com/k3s-io/k3s
RKE2_PKG=github.com/rancher/rke2
GO=${GO-go}
GOARCH=${GOARCH:-$("${GO}" env GOARCH)}
GOOS=${GOOS:-$("${GO}" env GOOS)}
if [ -z "$GOOS" ]; then
    if [ "${OS}" == "Windows_NT" ]; then
      GOOS="windows"
    else
      UNAME_S=$(shell uname -s)
		  if [ "${UNAME_S}" == "Linux" ]; then
			    GOOS="linux"
		  elif [ "${UNAME_S}" == "Darwin" ]; then
				  GOOS="darwin"
		  elif [ "${UNAME_S}" == "FreeBSD" ]; then
				  GOOS="freebsd"
		  fi
    fi
fi

GIT_TAG=$DRONE_TAG
TREE_STATE=clean
COMMIT=$DRONE_COMMIT
REVISION=$(git rev-parse HEAD)$(if ! git diff --no-ext-diff --quiet --exit-code; then echo .dirty; fi)
PLATFORM=${GOOS}-${GOARCH}
RELEASE=${PROG}.${PLATFORM}
# hardcode versions unless set specifically
KUBERNETES_VERSION=v1.23.12
KUBERNETES_IMAGE_TAG=v1.23.12-rke2r1-build20220921
ETCD_VERSION=${ETCD_VERSION:-v3.5.4-k3s1}
PAUSE_VERSION=${PAUSE_VERSION:-3.6}
CCM_VERSION=${CCM_VERSION:-v0.0.3-build20211118}

VERSION="${KUBERNETES_VERSION}+rke2r1"

if [[ "${VERSION}" =~ ^v([0-9]+)\.([0-9]+)(\.[0-9]+)?([-+].*)?$ ]]; then
    VERSION_MAJOR=${BASH_REMATCH[1]}
    VERSION_MINOR=${BASH_REMATCH[2]}
fi

DOCKERIZED_VERSION="${VERSION/+/-}" # this mimics what kubernetes builds do
