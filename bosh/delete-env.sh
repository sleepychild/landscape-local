#!/bin/bash

set -eu

STEP() { echo ; echo ; echo "==\\" ; echo "===>" "$@" ; echo "==/" ; echo ; }

bosh_deployment="$(cd "$(dirname "${BASH_SOURCE[0]}")"; cd ..; cd bosh-deployment; pwd)"

echo "This will destroy BOSH from VirtualBox."
echo

read -p "Continue? [yN] "
[[ $REPLY =~ ^[Yy]$ ]] || exit 1

####
STEP "Remove environment alias"
####

bosh unalias-env vbox

####
STEP "Deleting BOSH Director"
####

bosh delete-env \
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

####
STEP "Remove director from known hosts"
####

ssh-keygen -f ~/.ssh/known_hosts -R "192.168.50.6"

####
STEP "Delete creds"
####

rm creds.yml
rm ssh_key
