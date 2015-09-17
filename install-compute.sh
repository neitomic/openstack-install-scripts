#!/bin/bash

export BASE_DIR=$( cd `dirname $0` && pwd )

source ${BASE_DIR}/common/openstack.conf

echo "Add hostname to /etc/host ..."
${BASE_DIR}/tools/addHost.sh | tee ${BASE_DIR}/log/compute.log
echo "Done."
echo "Installing Network Time Protocol ..."
${BASE_DIR}/scripts/install-ntp-compute.sh | tee ${BASE_DIR}/log/compute.log
echo "Done."
echo "Installing OpenStack packages..."
${BASE_DIR}/scripts/install-openstack-package.sh | tee ${BASE_DIR}/log/compute.log
echo "Done."


echo "Installing Nova..."
${BASE_DIR}/scripts/install-nova-compute.sh | tee ${BASE_DIR}/log/compute.log
echo "Done."