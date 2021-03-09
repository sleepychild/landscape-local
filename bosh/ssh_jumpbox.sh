#!/bin/bash

set -eu -o pipefail

ssh -i <(bosh int  creds.yml --path /jumpbox_ssh/private_key) jumpbox@192.168.50.6
