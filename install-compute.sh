#!/bin/bash

export BASE_DIR=$( cd `dirname $0` && pwd )

source ${BASE_DIR}/common/openstack.conf
mkdir ${BASE_DIR}/log
touch ${BASE_DIR}/log/compute.log
echo "Add hostname to /etc/host ..."
${BASE_DIR}/tools/addHost.sh | tee -a ${BASE_DIR}/log/compute.log
echo "Done."
echo "Installing Network Time Protocol ..."
${BASE_DIR}/scripts/env/install-ntp-compute.sh | tee -a ${BASE_DIR}/log/compute.log
echo "Done."
echo "Installing OpenStack packages..."
${BASE_DIR}/scripts/env/install-openstack-package.sh | tee -a ${BASE_DIR}/log/compute.log
echo "Done."


echo "Installing Nova..."
${BASE_DIR}/scripts/nova/install-nova-compute.sh | tee -a ${BASE_DIR}/log/compute.log
echo "Done."