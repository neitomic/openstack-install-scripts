#!/bin/bash

openstack-config --set /etc/neutron/neutron.conf DEFAULT \
  core_plugin neutron.plugins.ml2.plugin.Ml2Plugin
openstack-config --set /etc/neutron/neutron.conf DEFAULT \
  service_plugins neutron.services.l3_router.l3_router_plugin.L3RouterPlugin

su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugin.ini upgrade head" neutron  

service neutron-server stop
service neutron-server start