#!/bin/bash

echo "Configuring nova service..."
openstack-config --set /etc/nova/nova.conf DEFAULT \
  network_api_class nova.network.api.API
openstack-config --set /etc/nova/nova.conf DEFAULT \
  security_group_api nova

echo "Restart nova services..."
service openstack-nova-api restart
service openstack-nova-scheduler restart
service openstack-nova-conductor restart

echo "Done!"