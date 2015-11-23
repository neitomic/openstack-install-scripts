#!/bin/bash

PARENT_DIR=$( cd `dirname $0`/../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

echo "Create keystone database and gain permision..."
CINDER_SQL_FILE=${CINDER_SQL_FILE:-$BASE_DIR/sql_scripts/create_db_cinder.sql}
sed -i "s/CINDER_DBPASS/${KEYSTONE_DBPASS}/g" ${CINDER_SQL_FILE}
mysql -u "root" "-p${MYSQL_PASS}" < ${CINDER_SQL_FILE}
sed -i "s/${CINDER_DBPASS}/CINDER_DBPASS/g" ${CINDER_SQL_FILE}
echo "Done."

source ${BASE_DIR}/admin-openrc.sh

openstack user create --password ${CINDER_PASS} cinder
openstack role add --project service --user cinder admin
openstack service create --name cinder \
  --description "OpenStack Block Storage" volume

openstack service create --name cinderv2 \
  --description "OpenStack Block Storage" volumev2

openstack endpoint create \
  --publicurl http://controller:8776/v2/%\(tenant_id\)s \
  --internalurl http://controller:8776/v2/%\(tenant_id\)s \
  --adminurl http://controller:8776/v2/%\(tenant_id\)s \
  --region RegionOne \
  volume

openstack endpoint create \
  --publicurl http://controller:8776/v2/%\(tenant_id\)s \
  --internalurl http://controller:8776/v2/%\(tenant_id\)s \
  --adminurl http://controller:8776/v2/%\(tenant_id\)s \
  --region RegionOne \
  volumev2

yum install -y openstack-cinder python-cinderclient python-oslo-db

# cp /usr/share/cinder/cinder-dist.conf /etc/cinder/cinder.conf
# chown -R cinder:cinder /etc/cinder/cinder.conf


if [ "${DEBUG}" == "ON" ]; then
	sed -i "/^\[DEFAULT\]$/a verbose = True" /etc/cinder/cinder.conf
fi

sed -i "/^\[database\]$/a connection = mysql://cinder:${CINDER_DBPASS}@controller/cinder" /etc/cinder/cinder.conf

sed -i "/^\[DEFAULT\]$/a rpc_backend = rabbit\n\
auth_strategy = keystone\n\
my_ip = ${CONTROLLER_IP}" /etc/cinder/cinder.conf

sed -i "/^\[oslo_messaging_rabbit\]$/a rabbit_host = controller\n\
rabbit_userid = openstack\n\
rabbit_password = ${RABBIT_PASS}" /etc/cinder/cinder.conf
 
sed -i "/^\[keystone_authtoken\]$/a auth_uri = http://controller:5000\n\
auth_url = http://controller:35357\n\
auth_plugin = password\n\
project_domain_id = default\n\
user_domain_id = default\n\
project_name = service\n\
username = cinder\n\
password = ${CINDER_PASS}" /etc/cinder/cinder.conf

echo "

[oslo_concurrency]
lock_path = /var/lock/cinder" >> /etc/cinder/cinder.conf


su -s /bin/sh -c "cinder-manage db sync" cinder

systemctl enable openstack-cinder-api.service openstack-cinder-scheduler.service
systemctl start openstack-cinder-api.service openstack-cinder-scheduler.service