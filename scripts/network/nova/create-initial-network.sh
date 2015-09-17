#!/bin/bash

PARENT_DIR=$( cd `dirname $0`/../../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

PHYSICAL_NETWORK_PREFIX=${PHYSICAL_NETWORK_PREFIX:-"172.28.181"}
source ${BASE_DIR}/admin-openrc.sh

nova network-create demo-net --bridge br100 --multi-host T \
  --fixed-range-v4 ${PHYSICAL_NETWORK_PREFIX}.24/29