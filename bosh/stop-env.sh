#!/bin/bash

set -eu -o pipefail

STEP() { echo ; echo ; echo "==\\" ; echo "===>" "$@" ; echo "==/" ; echo ; }

bosh_deployment="$(cd "$(dirname "${BASH_SOURCE[0]}")"; cd ..; cd bosh-deployment; pwd)"
bosh_deployment_sha="$(cd "${bosh_deployment}"; git rev-parse --short HEAD)"

if [ "${PWD##${bosh_deployment}}" != "${PWD}" ] || [ -e virtualbox/create-env.sh ] || [ -e ../virtualbox/create-env.sh ]; then
  echo "It looks like you are running this within the ${bosh_deployment} repository."
  echo "To avoid secrets ending up in this repo, run this from another directory."
  echo

  exit 1
fi

####
STEP "Creating BOSH Director"
####

bosh stop-env \
  "${bosh_deployment}/bosh.yml" \
  --state "${PWD}/state.json" \
  --ops-file "${bosh_deployment}/virtualbox/cpi.yml" \
  --ops-file "${bosh_deployment}/virtualbox/outbound-network.yml" \
  --ops-file "${bosh_deployment}/bosh-lite.yml" \
  --ops-file "${bosh_deployment}/uaa.yml" \
  --ops-file "${bosh_deployment}/credhub.yml" \
  --ops-file "${bosh_deployment}/jumpbox-user.yml" \
  --ops-file "${PWD}/landscape-local.yml" \
  --vars-store "${PWD}/creds.yml" \
  -v director_name=bosh-lite \
  -v internal_ip=192.168.50.6 \
  -v internal_gw=192.168.50.1 \
  -v internal_cidr=192.168.50.0/24 \
  -v network_name=vboxnet0 \
  -v outbound_network_name=NatNetwork
