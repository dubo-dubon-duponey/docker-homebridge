#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

export TITLE="Homebridge"
export DESCRIPTION="A dubo image for Homebridge"
export IMAGE_NAME="homebridge"
export PLATFORMS="linux/amd64,linux/arm64,linux/arm/v7" # linux/arm/v6 is not supported for lack of node

# shellcheck source=/dev/null
. "$(cd "$(dirname "${BASH_SOURCE[0]:-$PWD}")" 2>/dev/null 1>&2 && pwd)/helpers.sh"
