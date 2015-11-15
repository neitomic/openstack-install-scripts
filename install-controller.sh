#!/bin/bash

export BASE_DIR=$( cd `dirname $0` && pwd )

mkdir -p ${BASE_DIR}/log
touch ${BASE_DIR}/log/controller.log

source ${BASE_DIR}/common/openstack.conf

echo "Add hostname to /etc/host ..."
${BASE_DIR}/tools/addHost.sh | tee ${BASE_DIR}/log/controller.log
echo "Done."
echo "Installing Network Time Protocol ..."
${BASE_DIR}/scripts/env/install-ntp-controller.sh | tee ${BASE_DIR}/log/controller.log
echo "Done."
echo "Installing OpenStack packages..."
${BASE_DIR}/scripts/env/install-openstack-package.sh | tee ${BASE_DIR}/log/controller.log
echo "Done."
echo "Installing SQL database..."
${BASE_DIR}/scripts/env/install-mariadb.sh | tee ${BASE_DIR}/log/controller.log
echo "Done."
echo "Installing Message queue (RabbitMq) ..."
${BASE_DIR}/scripts/env/install-rabbitmq.sh | tee ${BASE_DIR}/log/controller.log
echo "Done."

echo "Installing KeyStone..."
${BASE_DIR}/scripts/keystone/install-keystone.sh | tee ${BASE_DIR}/log/controller.log
echo "Done."

echo "Installing Glance..."
${BASE_DIR}/scripts/glance/install-glance.sh | tee ${BASE_DIR}/log/controller.log
echo "Done."

echo "Installing Nova..."
${BASE_DIR}/scripts/nova/install-nova-controller.sh | tee ${BASE_DIR}/log/controller.log
echo "Done."

echo "Configuring Nova-Network..."
${BASE_DIR}/scripts/network/nova/controller.sh | tee ${BASE_DIR}/log/controller.log
echo "Done."