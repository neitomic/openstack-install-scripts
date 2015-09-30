#!/bin/bash

PARENT_DIR=$( cd `dirname $0`/../../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}


echo "Prerequisites..."

SYSCTL_CONF=/etc/sysctl.conf
grep -q "^net.ipv4.ip_forward=" ${SYSCTL_CONF} && sed "s/^net.ipv4.ip_forward=.*/net.ipv4.ip_forward=1/" -i ${SYSCTL_CONF} || 
    sed "$ a\net.ipv4.ip_forward=1" -i ${SYSCTL_CONF}

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

echo "Install the Networking components..."
yum install -y openstack-neutron openstack-neutron-ml2 openstack-neutron-openvswitch > /dev/null


echo "Configure the Networking common components..."
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


echo "Configure the Layer-3 (L3) agent..."
openstack-config --set /etc/neutron/l3_agent.ini DEFAULT \
  interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
openstack-config --set /etc/neutron/l3_agent.ini DEFAULT \
  use_namespaces True

echo "Configure the DHCP agent..."
openstack-config --set /etc/neutron/dhcp_agent.ini DEFAULT \
  interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
openstack-config --set /etc/neutron/dhcp_agent.ini DEFAULT \
  dhcp_driver neutron.agent.linux.dhcp.Dnsmasq
openstack-config --set /etc/neutron/dhcp_agent.ini DEFAULT \
  use_namespaces True
openstack-config --set /etc/neutron/dhcp_agent.ini DEFAULT \
  dnsmasq_config_file /etc/neutron/dnsmasq-neutron.conf

echo "dhcp-option-force=26,1454" > /etc/neutron/dnsmasq-neutron.conf

killall dnsmasq

echo "Configure the metadata agent..."
openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT \
  auth_url http://controller:5000/v2.0
openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT \
  auth_region regionOne
openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT \
  admin_tenant_name service
openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT \
  admin_user neutron
openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT \
  admin_password ${NEUTRON_PASS}}
openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT \
  nova_metadata_ip controller
openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT \
  metadata_proxy_shared_secret ${METADATA_SECRET}




echo "Configure the Modular Layer 2 (ML2) plug-in..."
openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 \
  type_drivers gre
openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 \
  tenant_network_types gre
openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 \
  mechanism_drivers openvswitch
openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_gre \
  tunnel_id_ranges 1:1000

MY_IP=$(${BASE_DIR}/tools/getIPAddress.sh)
INSTANCE_TUNNELS_INTERFACE_IP_ADDRESS=${MY_IP}
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


echo "Configure the Open vSwitch (OVS) service..."
service openvswitch start
chkconfig openvswitch on

ovs-vsctl add-br br-int
ovs-vsctl add-br br-ex
ovs-vsctl add-port br-ex ${INTERFACE_NAME}


# ethtool -K INTERFACE_NAME gro off
echo "Finalize the installation..."
ln -s plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
cp /etc/init.d/neutron-openvswitch-agent /etc/init.d/neutron-openvswitch-agent.orig
sed -i 's,plugins/openvswitch/ovs_neutron_plugin.ini,plugin.ini,g' /etc/init.d/neutron-openvswitch-agent
service neutron-openvswitch-agent start
service neutron-l3-agent start
service neutron-dhcp-agent start
service neutron-metadata-agent start
chkconfig neutron-openvswitch-agent on
chkconfig neutron-l3-agent on
chkconfig neutron-dhcp-agent on
chkconfig neutron-metadata-agent on



