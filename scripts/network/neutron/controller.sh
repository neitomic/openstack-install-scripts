#!/bin/bash

PARENT_DIR=$( cd `dirname $0`/../../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

echo "Create neutron database..."
NEUTRON_SQL_FILE=${NEUTRON_SQL_FILE:-$BASE_DIR/sql_scripts/create_db_neutron.sql}
sed -i "s/NEUTRON_DBPASS/${NEUTRON_DBPASS}/g" ${NEUTRON_SQL_FILE}
mysql -u "root" "-p${MYSQL_PASS}" < ${NEUTRON_SQL_FILE}
sed -i "s/${NEUTRON_DBPASS}/NEUTRON_DBPASS/g" ${NEUTRON_SQL_FILE}
echo "Done."

source ${BASE_DIR}/admin-openrc.sh

openstack user create --password ${NEUTRON_PASS} neutron

openstack role add --project service --user neutron admin
openstack service create --name neutron \
  --description "OpenStack Networking" network

openstack endpoint create \
  --publicurl http://controller:9696 \
  --adminurl http://controller:9696 \
  --internalurl http://controller:9696 \
  --region RegionOne \
  network

yum install -y openstack-neutron openstack-neutron-ml2 python-neutronclient which

sed -i "/^\[database\]$/a connection = mysql://neutron:${NEUTRON_DBPASS}@controller/neutron" /etc/neutron/neutron.conf

sed -i "/^\[DEFAULT\]$/a rpc_backend = rabbit\n\
auth_strategy = keystone\n\
core_plugin = ml2\n\
service_plugins = router\n\
allow_overlapping_ips = True\n\
notify_nova_on_port_status_changes = True\n\
notify_nova_on_port_data_changes = True\n\
nova_url = http://controller:8774/v2" /etc/neutron/neutron.conf



sed -i "/^\[oslo_messaging_rabbit\]$/a rabbit_host = controller\n\
rabbit_userid = openstack\n\
rabbit_password = ${RABBIT_PASS}" /etc/neutron/neutron.conf

sed -i "/^\[keystone_authtoken\]$/a auth_uri = http://controller:5000\n\
auth_url = http://controller:35357\n\
auth_plugin = password\n\
project_domain_id = default\n\
user_domain_id = default\n\
project_name = service\n\
username = neutron\n\
password = ${NEUTRON_PASS}" /etc/neutron/neutron.conf


sed -i "/^\[nova\]$/a auth_url = http://controller:35357\n\
auth_plugin = password\n\
project_domain_id = default\n\
user_domain_id = default\n\
region_name = RegionOne\n\
project_name = service\n\
username = nova\n\
password = ${NOVA_PASS}" /etc/neutron/neutron.conf

sed -i "/^\[ml2\]$/a type_drivers = flat,vlan,gre,vxlan\n\
tenant_network_types = gre\n\
mechanism_drivers = openvswitch" /etc/neutron/plugins/ml2/ml2_conf.ini

sed -i "/^\[ml2_type_gre\]$/a tunnel_id_ranges = 1:1000" /etc/neutron/plugins/ml2/ml2_conf.ini

sed -i "/^\[securitygroup\]$/a enable_security_group = True\n\
enable_ipset = True\n\
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver" /etc/neutron/plugins/ml2/ml2_conf.ini

sed -i "/^\[DEFAULT\]$/a network_api_class = nova.network.neutronv2.api.API\n\
security_group_api = neutron\n\
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver\n\
firewall_driver = nova.virt.firewall.NoopFirewallDriver" /etc/nova/nova.conf

sed -i "/^\[neutron\]$/a url = http://controller:9696\n\
auth_strategy = keystone\n\
admin_auth_url = http://controller:35357/v2.0\n\
admin_tenant_name = service\n\
admin_username = neutron\n\
admin_password = ${NEUTRON_PASS}" /etc/nova/nova.conf

ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

systemctl restart openstack-nova-api.service openstack-nova-scheduler.service \
  openstack-nova-conductor.service

systemctl enable neutron-server.service
systemctl start neutron-server.service



