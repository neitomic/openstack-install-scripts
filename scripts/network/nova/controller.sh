#!/bin/bash

sed -i "/^\[DEFAULT\]$/a network_api_class = nova.network.api.API\n\
security_group_api = nova" /etc/nova/nova.conf

systemctl restart openstack-nova-api.service openstack-nova-scheduler.service \
  openstack-nova-conductor.service