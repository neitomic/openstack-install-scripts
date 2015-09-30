#!/bin/bash

PARENT_DIR=$( cd `dirname $0`/../../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}


echo "Prerequisites..."

SYSCTL_CONF=/etc/sysctl.conf

grep -q "^net.ipv4.conf.all.rp_filter=" ${SYSCTL_CONF} && sed "s/^net.ipv4.conf.all.rp_filter=.*/net.ipv4.conf.all.rp_filter=0/" -i ${SYSCTL_CONF} || 
    sed "$ a\net.ipv4.conf.all.rp_filter=0" -i ${SYSCTL_CONF}

grep -q "^net.ipv4.conf.default.rp_filter=" ${SYSCTL_CONF} && sed "s/^net.ipv4.conf.default.rp_filter=.*/net.ipv4.conf.default.rp_filter=0/" -i ${SYSCTL_CONF} || 
    sed "$ a\net.ipv4.conf.default.rp_filter=0" -i ${SYSCTL_CONF}

grep -q "^net.bridge.bridge-nf-call-arptables=" ${SYSCTL_CONF} && sed "s/^net.bridge.bridge-nf-call-arptables=.*/net.bridge.bridge-nf-call-arptables=1/" -i ${SYSCTL_CONF} || 
    sed "$ a\net.bridge.bridge-nf-call-arptables=1" -i ${SYSCTL_CONF}

grep -q "^net.bridge.bridge-nf-call-iptables=" ${SYSCTL_CONF} && sed "s/^net.bridge.bridge-nf-call-iptables=.*/net.bridge.bridge-nf-call-iptables=1/" -i ${SYSCTL_CONF} || 
    sed "$ a\net.bridge.bridge-nf-call-iptables=1" -i ${SYSCTL_CONF}

grep -q "^net.bridge.bridge-nf-call-ip6tables=" ${SYSCTL_CONF} && sed "s/^net.bridge.bridge-nf-call-ip6tables=.*/net.bridge.bridge-nf-call-ip6tables=1/" -i ${SYSCTL_CONF} || 
    sed "$ a\net.bridge.bridge-nf-call-ip6tables=1" -i ${SYSCTL_CONF}

sysctl -p


yum install -y openstack-neutron-ml2 openstack-neutron-openvswitch > /dev/null

openstack-config --set /etc/neutron/neutron.conf DEFAULT \
  auth_strategy keystone
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken \
  auth_uri http://controller:5000
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken \
  auth_host controller
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken \
  auth_protocol http
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken \
  auth_port 35357
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken \
  admin_tenant_name service
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken \
  admin_user neutron
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken \
  admin_password ${NEUTRON_PASS}

openstack-config --set /etc/neutron/neutron.conf DEFAULT \
  rpc_backend neutron.openstack.common.rpc.impl_qpid
openstack-config --set /etc/neutron/neutron.conf DEFAULT \
  qpid_hostname controller

openstack-config --set /etc/neutron/neutron.conf DEFAULT \
  core_plugin ml2
openstack-config --set /etc/neutron/neutron.conf DEFAULT \
  service_plugins router

openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 \
  type_drivers gre
openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 \
  tenant_network_types gre
openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 \
  mechanism_drivers openvswitch
openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_gre \
  tunnel_id_ranges 1:1000


MY_IP_TMP=$(${BASE_DIR}/tools/getIPAddress.sh)
INSTANCE_TUNNELS_INTERFACE_IP_ADDRESS=${MY_IP:-$MY_IP_TMP}

openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs \
  local_ip INSTANCE_TUNNELS_INTERFACE_IP_ADDRESS
openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs \
  tunnel_type gre
openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs \
  enable_tunneling True
openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup \
  firewall_driver neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup \
  enable_security_group True

service openvswitch start
chkconfig openvswitch on

ovs-vsctl add-br br-int

openstack-config --set /etc/nova/nova.conf DEFAULT \
  network_api_class nova.network.neutronv2.api.API
openstack-config --set /etc/nova/nova.conf DEFAULT \
  neutron_url http://controller:9696
openstack-config --set /etc/nova/nova.conf DEFAULT \
  neutron_auth_strategy keystone
openstack-config --set /etc/nova/nova.conf DEFAULT \
  neutron_admin_tenant_name service
openstack-config --set /etc/nova/nova.conf DEFAULT \
  neutron_admin_username neutron
openstack-config --set /etc/nova/nova.conf DEFAULT \
  neutron_admin_password ${NEUTRON_PASS}
openstack-config --set /etc/nova/nova.conf DEFAULT \
  neutron_admin_auth_url http://controller:35357/v2.0
openstack-config --set /etc/nova/nova.conf DEFAULT \
  linuxnet_interface_driver nova.network.linux_net.LinuxOVSInterfaceDriver
openstack-config --set /etc/nova/nova.conf DEFAULT \
  firewall_driver nova.virt.firewall.NoopFirewallDriver
openstack-config --set /etc/nova/nova.conf DEFAULT \
  security_group_api neutron

ln -s plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

cp /etc/init.d/neutron-openvswitch-agent /etc/init.d/neutron-openvswitch-agent.orig
sed -i 's,plugins/openvswitch/ovs_neutron_plugin.ini,plugin.ini,g' /etc/init.d/neutron-openvswitch-agent

service openstack-nova-compute restart

service neutron-openvswitch-agent start
chkconfig neutron-openvswitch-agent on