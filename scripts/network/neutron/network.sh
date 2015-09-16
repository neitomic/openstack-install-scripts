#!/bin/bash

PARENT_DIR=$( cd `dirname $0`/../../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}


SYSCTL_CONF=/etc/sysctl.conf
grep -q "^net.ipv4.ip_forward=" ${SYSCTL_CONF} && sed "s/^net.ipv4.ip_forward=.*/net.ipv4.ip_forward=1/" -i ${SYSCTL_CONF} || 
    sed "$ a\net.ipv4.ip_forward=1" -i ${SYSCTL_CONF}

grep -q "^net.ipv4.conf.all.rp_filter=" ${SYSCTL_CONF} && sed "s/^net.ipv4.conf.all.rp_filter=.*/net.ipv4.conf.all.rp_filter=0/" -i ${SYSCTL_CONF} || 
    sed "$ a\net.ipv4.conf.all.rp_filter=0" -i ${SYSCTL_CONF}

grep -q "^net.ipv4.conf.default.rp_filter=" ${SYSCTL_CONF} && sed "s/^net.ipv4.conf.default.rp_filter=.*/net.ipv4.conf.default.rp_filter=0/" -i ${SYSCTL_CONF} || 
    sed "$ a\net.ipv4.conf.default.rp_filter=0" -i ${SYSCTL_CONF}

sysctl -p

yum install -y openstack-neutron openstack-neutron-ml2 openstack-neutron-openvswitch

sed -i "/^\[DEFAULT\]$/a rpc_backend = rabbit\n\
auth_strategy = keystone\n\
core_plugin = ml2\n\
service_plugins = router\n\
allow_overlapping_ips = True" /etc/neutron/neutron.conf

sed -i "/^\[oslo_messaging_rabbit\]/a rabbit_host = controller\n\
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

