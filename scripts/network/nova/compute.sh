#!/bin/bash

yum -y install openstack-nova-network openstack-nova-api > /dev/null

sed -i "/^\[DEFAULT\]$/a network_api_class = nova.network.api.API\n\
security_group_api = nova\n\
firewall_driver = nova.virt.firewall.NoopFirewallDriver\n\
network_manager = nova.network.manager.FlatDHCPManager\n\
network_size = 254\n\
allow_same_net_traffic = False\n\
multi_host = True\n\
send_arp_for_ha = True\n\
share_dhcp_address = True\n\
force_dhcp_release = True\n\
flat_network_bridge = br100\n\
flat_interface = ${INTERFACE_NAME}\n\
public_interface = ${INTERFACE_NAME}" /etc/nova/nova.conf


systemctl enable openstack-nova-network.service openstack-nova-metadata-api.service
systemctl start openstack-nova-network.service openstack-nova-metadata-api.service
