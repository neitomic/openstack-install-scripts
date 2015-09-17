#!/bin/bash

echo "Installing Nova Network packages..."
yum install -y openstack-nova-network openstack-nova-api > /dev/null
echo "Done."

echo "Configuring nova network..."
openstack-config --set /etc/nova/nova.conf DEFAULT \
  network_api_class nova.network.api.API
openstack-config --set /etc/nova/nova.conf DEFAULT \
  security_group_api nova
openstack-config --set /etc/nova/nova.conf DEFAULT \
  network_manager nova.network.manager.FlatDHCPManager
openstack-config --set /etc/nova/nova.conf DEFAULT \
  firewall_driver nova.virt.libvirt.firewall.IptablesFirewallDriver
openstack-config --set /etc/nova/nova.conf DEFAULT \
  network_size 254
openstack-config --set /etc/nova/nova.conf DEFAULT \
  allow_same_net_traffic False
openstack-config --set /etc/nova/nova.conf DEFAULT \
  multi_host True
openstack-config --set /etc/nova/nova.conf DEFAULT \
  send_arp_for_ha True
openstack-config --set /etc/nova/nova.conf DEFAULT \
  share_dhcp_address True
openstack-config --set /etc/nova/nova.conf DEFAULT \
  force_dhcp_release True
openstack-config --set /etc/nova/nova.conf DEFAULT \
  flat_network_bridge br100
openstack-config --set /etc/nova/nova.conf DEFAULT \
  flat_interface ${INTERFACE_NAME}
openstack-config --set /etc/nova/nova.conf DEFAULT \
  public_interface ${INTERFACE_NAME}
echo "Done."

echo "Enable and start nova network services..."
service openstack-nova-network start
service openstack-nova-metadata-api start
chkconfig openstack-nova-network on
chkconfig openstack-nova-metadata-api on
echo "Done!"