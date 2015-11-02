#!/bin/bash

PARENT_DIR=$( cd `dirname $0`/../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

echo "Create glance database and gain permision..."

GLANCE_SQL_FILE=${GLANCE_SQL_FILE:-$BASE_DIR/sql_scripts/create_db_glance.sql}
sed -i "s/GLANCE_DBPASS/${GLANCE_DBPASS}/g" ${GLANCE_SQL_FILE}
mysql -u "root" "-p${MYSQL_PASS}" < ${GLANCE_SQL_FILE} > /dev/null
sed -i "s/${GLANCE_DBPASS}/GLANCE_DBPASS/g" ${GLANCE_SQL_FILE}
echo "Done."

source ${BASE_DIR}/admin-openrc.sh

echo "Create glance user..."
openstack user create --password ${GLANCE_PASS} glance

echo "Add glance user to admin role..."
openstack role add --project service --user glance admin

echo "Create image service..."
openstack service create --name glance \
  --description "OpenStack Image service" image

echo "Create endpoint for image service..."
openstack endpoint create \
  --publicurl http://controller:9292 \
  --internalurl http://controller:9292 \
  --adminurl http://controller:9292 \
  --region RegionOne \
  image


echo "Installing glance packages..."
yum install -y openstack-glance python-glance python-glanceclient > /dev/null
echo "Done."

echo "Adding glance configuration..."
sed -i "/^\[database\]$/a connection = mysql://glance:${GLANCE_DBPASS}@controller/glance" /etc/glance/glance-api.conf
sed -i "/^\[keystone_authtoken\]$/a auth_uri = http://controller:5000\n\
auth_url = http://controller:35357\n\
auth_plugin = password\n\
project_domain_id = default\n\
user_domain_id = default\n\
project_name = service\n\
username = glance\n\
password = ${GLANCE_PASS}" /etc/glance/glance-api.conf

sed -i "/^\[paste_deploy\]$/a flavor = keystone" /etc/glance/glance-api.conf
sed -i "/^\[glance_store\]$/a default_store = file\n\
filesystem_store_datadir = /var/lib/glance/images/" /etc/glance/glance-api.conf

sed -i "/^\[DEFAULT\]$/a notification_driver = noop" /etc/glance/glance-api.conf

sed -i "/^\[database\]$/a connection = mysql://glance:${GLANCE_DBPASS}@controller/glance" /etc/glance/glance-registry.conf
sed -i "/^\[keystone_authtoken\]$/a auth_uri = http://controller:5000\n\
auth_url = http://controller:35357\n\
auth_plugin = password\n\
project_domain_id = default\n\
user_domain_id = default\n\
project_name = service\n\
username = glance\n\
password = ${GLANCE_PASS}" /etc/glance/glance-registry.conf

sed -i "/^\[paste_deploy\]$/a flavor = keystone" /etc/glance/glance-registry.conf

sed -i "/^\[DEFAULT\]$/a notification_driver = noop" /etc/glance/glance-registry.conf

echo "Sync glance configuration to database..."
su -s /bin/sh -c "glance-manage db_sync" glance
echo "Done."

echo "Enable openstack glance services..."
systemctl enable openstack-glance-api.service openstack-glance-registry.service > /dev/null
echo "Start openstack glance services..."
systemctl start openstack-glance-api.service openstack-glance-registry.service > /dev/null
echo "Done."

echo "DONE! Have a good day!"


