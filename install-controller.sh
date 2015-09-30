#!/bin/bash

export BASE_DIR=$( cd `dirname $0` && pwd )
mkdir ${BASE_DIR}/log
touch ${BASE_DIR}/log/controller.log
touch ${BASE_DIR}/log/verify.log

source ${BASE_DIR}/common/openstack.conf

echo "Add hostname to /etc/host ..."
${BASE_DIR}/tools/addHost.sh | tee -a ${BASE_DIR}/log/controller.log
echo "Done."
echo "Installing Network Time Protocol ..."
${BASE_DIR}/scripts/env/install-ntp-controller.sh | tee -a ${BASE_DIR}/log/controller.log
echo "Done."
echo "Installing OpenStack packages..."
${BASE_DIR}/scripts/env/install-openstack-package.sh | tee -a ${BASE_DIR}/log/controller.log
echo "Done."
echo "Installing SQL database..."
${BASE_DIR}/scripts/env/install-mysql-controller.sh | tee -a ${BASE_DIR}/log/controller.log
echo "Done."
echo "Installing Message queue (QPid) ..."
${BASE_DIR}/scripts/env/install-qpid.sh | tee -a ${BASE_DIR}/log/controller.log
echo "Done."

# echo "Compile and install GPM 6"
# touch ${BASE_DIR}/log/gpm.log
# ${BASE_DIR}/scripts/env/gpm-install.sh | tee -a ${BASE_DIR}/log/gpm.log

echo "Installing KeyStone..."
${BASE_DIR}/scripts/keystone/install-keystone-controller.sh | tee -a ${BASE_DIR}/log/controller.log
echo "Done."

echo "Verifing KeyStone service...."
${BASE_DIR}/test/verify/keystone.sh | tee -a ${BASE_DIR}/log/verify.log

echo "Installing Glance..."
${BASE_DIR}/scripts/glance/install-glance-controller.sh | tee -a ${BASE_DIR}/log/controller.log
echo "Done."

echo "Verifing Glance service...."
${BASE_DIR}/test/verify/glance.sh | tee -a ${BASE_DIR}/log/verify.log

echo "Installing Nova..."
${BASE_DIR}/scripts/nova/install-nova-controller.sh | tee -a ${BASE_DIR}/log/controller.log
echo "Done."
echo "Verifing Nova service...."
${BASE_DIR}/test/verify/nova-controller.sh | tee -a ${BASE_DIR}/log/verify.log

echo "Configure nova network..."
${BASE_DIR}/scripts/network/nova/controller.sh | tee -a ${BASE_DIR}/log/controller.log
