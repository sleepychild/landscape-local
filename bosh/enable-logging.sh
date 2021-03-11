#!/bin/bash

set -eu -o pipefail

export BOSH_LOG_LEVEL="debug"
export BOSH_LOG_PATH="${PWD}/bosh.log"
