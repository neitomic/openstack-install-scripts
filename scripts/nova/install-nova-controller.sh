#!/bin/bash

PARENT_DIR=$( cd `dirname $0`/../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

echo "##########################################"
echo "##         Compute services             ##"
echo "##########################################"

echo "Installing OpenStack nova packages..."
yum install -y openstack-nova-api openstack-nova-cert openstack-nova-conductor \
  openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler \
  python-novaclient > /dev/null
echo "Done."

openstack-config --set /etc/nova/nova.conf \
  database connection mysql://nova:NOVA_DBPASS@controller/nova

openstack-config --set /etc/nova/nova.conf \
  DEFAULT rpc_backend qpid
openstack-config --set /etc/nova/nova.conf DEFAULT qpid_hostname controller

openstack-config --set /etc/nova/nova.conf DEFAULT my_ip ${CONTROLLER_IP}
openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_listen ${CONTROLLER_IP}
openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address ${CONTROLLER_IP}

echo "Create nova database..."
NOVA_SQL_FILE=${NOVA_SQL_FILE:-$BASE_DIR/sql_scripts/create_db_nova.sql}
sed -i "s/NOVA_DBPASS/${NOVA_DBPASS}/g" ${NOVA_SQL_FILE}
mysql -u "root" "-p${MYSQL_PASS}" < ${NOVA_SQL_FILE}
sed -i "s/${NOVA_DBPASS}/NOVA_DBPASS/g" ${NOVA_SQL_FILE}
echo "Done."

echo "Sync nova configuration to database..."
su -s /bin/sh -c "nova-manage db sync" nova
echo "Done."

source ${BASE_DIR}/admin-openrc.sh


echo "Create nova user using admin role..."
keystone user-create --name=nova --pass=${NOVA_PASS} --email=nova@example.com
keystone user-role-add --user=nova --tenant=service --role=admin

echo "Configuring nova service..."
openstack-config --set /etc/nova/nova.conf DEFAULT auth_strategy keystone
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_uri http://controller:5000
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_host controller
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_protocol http
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_port 35357
openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_user nova
openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_tenant_name service
openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_password ${NOVA_PASS}
echo "Done."

echo "Create compute service..."
keystone service-create --name=nova --type=compute \
  --description="OpenStack Compute"
echo "Create endpoint for compute service..."
keystone endpoint-create \
  --service-id=$(keystone service-list | awk '/ compute / {print $2}') \
  --publicurl=http://controller:8774/v2/%\(tenant_id\)s \
  --internalurl=http://controller:8774/v2/%\(tenant_id\)s \
  --adminurl=http://controller:8774/v2/%\(tenant_id\)s

echo "Enable and start nova services..."
service openstack-nova-api start
service openstack-nova-cert start
service openstack-nova-consoleauth start
service openstack-nova-scheduler start
service openstack-nova-conductor start
service openstack-nova-novncproxy start
chkconfig openstack-nova-api on
chkconfig openstack-nova-cert on
chkconfig openstack-nova-consoleauth on
chkconfig openstack-nova-scheduler on
chkconfig openstack-nova-conductor on
chkconfig openstack-nova-novncproxy on
echo "Done."

echo "DONE! Have a good day! :)"

echo "##########################################"
echo "##########################################"