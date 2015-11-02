#!/bin/bash

echo "Install rabbitmq packages..."
yum install -y rabbitmq-server > /dev/null
echo "Done."
echo "Enable and start rabbitmq service..."
systemctl enable rabbitmq-server.service > /dev/null
systemctl start rabbitmq-server.service > /dev/null
echo "Done."
echo "Create openstack user and gain permissions"
rabbitmqctl add_user openstack ${RABBIT_PASS} > /dev/null
rabbitmqctl set_permissions openstack ".*" ".*" ".*" > /dev/null
systemctl restart rabbitmq-server.service > /dev/null
echo "Done."

echo "DONE! Have a good day! :)"
