#!/bin/bash

set -eu -o pipefail

STEP() { echo ; echo ; echo "==\\" ; echo "===>" "$@" ; echo "==/" ; echo ; }

####
STEP "Adding Network Routes (sudo is required)"
####

if [ "$(uname)" = "Darwin" ]; then
  sudo route add -net 10.244.0.0/16 192.168.50.6
elif [ "$(uname)" = "Linux" ]; then
  if type ip > /dev/null 2>&1; then
    sudo ip route add 10.244.0.0/16 via 192.168.50.6
  elif type route > /dev/null 2>&1; then
    sudo route add -net 10.244.0.0/16 gw 192.168.50.6
  else
    echo "ERROR adding route"
    exit 1
  fi
fi
