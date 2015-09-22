#!/bin/bash

PARENT_DIR=$( cd `dirname $0`/../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

echo "##########################################"
echo "##         Compute services             ##"
echo "##########################################"

echo "Installing OpenStack Nova packages..."
yum install -y openstack-nova-compute > /dev/null
echo "Done."

echo "Configuring nova service..."
MY_IP=$(${BASE_DIR}/tools/getIPAddress.sh)

if [ "${DEBUG}" == "ON" ]; then
	openstack-config --set /etc/nova/nova.conf \
	DEFAULT verbose True
fi

openstack-config --set /etc/nova/nova.conf \
 database connection mysql://nova:${NOVA_DBPASS}@controller/nova
openstack-config --set /etc/nova/nova.conf DEFAULT auth_strategy keystone
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_uri http://controller:5000
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_host controller
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_protocol http
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_port 35357
openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_user nova
openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_tenant_name service
openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_password ${NOVA_PASS}

openstack-config --set /etc/nova/nova.conf \
  DEFAULT rpc_backend qpid
openstack-config --set /etc/nova/nova.conf DEFAULT qpid_hostname controller

openstack-config --set /etc/nova/nova.conf DEFAULT my_ip ${MY_IP}
openstack-config --set /etc/nova/nova.conf DEFAULT vnc_enabled True
openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_listen 0.0.0.0
openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address ${MY_IP}
openstack-config --set /etc/nova/nova.conf \
  DEFAULT novncproxy_base_url http://controller:6080/vnc_auto.html

openstack-config --set /etc/nova/nova.conf DEFAULT glance_host controller

KVM_SUPPORT=$(${BASE_DIR}/tools/kvmSupport.sh)
if [ ${KVM_SUPPORT} -eq 0 ]; then 
	openstack-config --set /etc/nova/nova.conf libvirt virt_type qemu
fi
echo "Done."

echo "Enable and start nova services..."
service libvirtd start
service messagebus start
service openstack-nova-compute start
chkconfig libvirtd on
chkconfig messagebus on
chkconfig openstack-nova-compute on
echo "DONE! Have a good day! :)"


echo "##########################################"
echo "##########################################"
