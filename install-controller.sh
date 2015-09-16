#!/bin/bash

export BASE_DIR=$( cd `dirname $0` && pwd )

source ${BASE_DIR}/common/openstack.conf

echo "Add hostname to /etc/host ..."
${BASE_DIR}/tools/addHost.sh | tee ${BASE_DIR}/log/controller.log
echo "Done."
echo "Installing Network Time Protocol ..."
${BASE_DIR}/scripts/install-ntp-controller.sh | tee ${BASE_DIR}/log/controller.log
echo "Done."
echo "Installing OpenStack packages..."
${BASE_DIR}/scripts/install-openstack-package.sh | tee ${BASE_DIR}/log/controller.log
echo "Done."
echo "Installing SQL database..."
${BASE_DIR}/scripts/install-mariadb.sh | tee ${BASE_DIR}/log/controller.log
echo "Done."
echo "Installing Message queue (RabbitMq) ..."
${BASE_DIR}/scripts/install-rabbitmq.sh | tee ${BASE_DIR}/log/controller.log
echo "Done."

echo "Installing KeyStone..."
${BASE_DIR}/scripts/install-keystone-controller.sh | tee ${BASE_DIR}/log/controller.log
echo "Done."

echo "Installing Glance..."
${BASE_DIR}/scripts/install-glance-controller.sh | tee ${BASE_DIR}/log/controller.log
echo "Done."

echo "Installing Nova..."
${BASE_DIR}/scripts/install-nova-controller.sh | tee ${BASE_DIR}/log/controller.log
echo "Done."