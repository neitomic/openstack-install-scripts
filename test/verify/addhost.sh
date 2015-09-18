#!/bin/bash

export BASE_DIR=$( cd $(dirname "$0")/../.. && pwd )

source ${BASE_DIR}/common/openstack.conf

${BASE_DIR}/tools/addHost.sh