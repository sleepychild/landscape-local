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
STEP "Generating .envrc"
####

cat > .envrc <<EOF
export BOSH_ENVIRONMENT=vbox
export BOSH_CA_CERT=\$( bosh interpolate ${PWD}/creds.yml --path /director_ssl/ca )
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=\$( bosh interpolate ${PWD}/creds.yml --path /admin_password )

export CREDHUB_SERVER=https://192.168.50.6:8844
export CREDHUB_CA_CERT="\$( bosh interpolate ${PWD}/creds.yml --path=/credhub_tls/ca )
\$( bosh interpolate ${PWD}/creds.yml --path=/uaa_ssl/ca )"
export CREDHUB_CLIENT=credhub-admin
export CREDHUB_SECRET=\$( bosh interpolate ${PWD}/creds.yml --path=/credhub_admin_client_secret )

EOF
echo "export BOSH_DEPLOYMENT_SHA=${bosh_deployment_sha}" >> .envrc


source .envrc

echo Succeeded


####
STEP "Configuring Environment Alias"
####

bosh \
  --environment 192.168.50.6 \
  --ca-cert <( bosh interpolate "${PWD}/creds.yml" --path /director_ssl/ca ) \
  alias-env vbox

# bosh unalias-env vbox is the command to remove an alias

####
STEP "Updating Cloud Config"
####

bosh -n update-cloud-config "${bosh_deployment}/warden/cloud-config.yml" \
  > /dev/null

echo Succeeded

####
STEP "Updating Runtime Config"
####

bosh -n update-runtime-config "${bosh_deployment}/runtime-configs/dns.yml" \
  > /dev/null

echo Succeeded

####
STEP "Completed"
####

echo "Credentials for your environment have been generated and stored in creds.yml."
echo "Details about the state of your VM have been stored in state.json."
echo "You should keep these files for future updates and to destroy your environment."
echo
echo "BOSH Director is now running. You may need to run the following before using bosh commands:"
echo
echo "    source .envrc"
echo
