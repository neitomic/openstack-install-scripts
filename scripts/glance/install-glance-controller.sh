#!/bin/bash

PARENT_DIR=$( cd `dirname $0`/../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

echo "##########################################"
echo "##           Image services             ##"
echo "##########################################"

echo "Installing glance packages..."
yum install -y openstack-glance python-glanceclient > /dev/null
echo "Done."

openstack-config --set /etc/glance/glance-api.conf database \
  connection mysql://glance:${GLANCE_DBPASS}@controller/glance
openstack-config --set /etc/glance/glance-registry.conf database \
  connection mysql://glance:${GLANCE_DBPASS}@controller/glance

echo "Create glance database and gain permision..."

GLANCE_SQL_FILE=${GLANCE_SQL_FILE:-$BASE_DIR/sql_scripts/create_db_glance.sql}
sed -i "s/GLANCE_DBPASS/${GLANCE_DBPASS}/g" ${GLANCE_SQL_FILE}
mysql -u "root" "-p${MYSQL_PASS}" < ${GLANCE_SQL_FILE} > /dev/null
sed -i "s/${GLANCE_DBPASS}/GLANCE_DBPASS/g" ${GLANCE_SQL_FILE}
echo "Done."

echo "Sync glance configuration to database..."
su -s /bin/sh -c "glance-manage db_sync" glance
echo "Done."

source ${BASE_DIR}/admin-openrc.sh

echo "Create glance user..."
keystone user-create --name=glance --pass=${GLANCE_PASS} \
   --email=glance@example.com

echo "Add glance user to admin role..."
keystone user-role-add --user=glance --tenant=service --role=admin

echo "Configuring glance..."

if [ "${DEBUG}" == "ON" ]; then
  openstack-config --set /etc/nova/nova.conf \
  DEFAULT verbose True
fi

openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
  auth_uri http://controller:5000
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
  auth_host controller
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
  auth_port 35357
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
  auth_protocol http
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
  admin_tenant_name service
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
  admin_user glance
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
  admin_password ${GLANCE_PASS}
openstack-config --set /etc/glance/glance-api.conf paste_deploy \
  flavor keystone
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken \
  auth_uri http://controller:5000
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken \
  auth_host controller
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken \
  auth_port 35357
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken \
  auth_protocol http
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken \
  admin_tenant_name service
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken \
  admin_user glance
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken \
  admin_password ${GLANCE_PASS}
openstack-config --set /etc/glance/glance-registry.conf paste_deploy \
  flavor keystone
echo "Done."


echo "Create image service..."
keystone service-create --name=glance --type=image \
  --description="OpenStack Image Service"

echo "Create endpoint for image service..."
keystone endpoint-create \
  --service-id=$(keystone service-list | awk '/ image / {print $2}') \
  --publicurl=http://controller:9292 \
  --internalurl=http://controller:9292 \
  --adminurl=http://controller:9292

echo "Start openstack glance services..."
service openstack-glance-api start > /dev/null
service openstack-glance-registry start > /dev/null

echo "Enable openstack glance services..."
chkconfig openstack-glance-api on
chkconfig openstack-glance-registry on
echo "Done."

echo "DONE! Have a good day!"
echo "##########################################"
echo "##########################################"


