#! /bin/bash

# At the moment, only amd64 builds are supported by the ./Dockerfile. 
: ${CSI_PROW_BUILD_PLATFORMS:="linux amd64"}

# shellcheck disable=SC1091
. release-tools/prow.sh

gcr_cloud_build
