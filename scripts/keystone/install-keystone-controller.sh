#!/bin/bash

PARENT_DIR=$( cd `dirname $0`/../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

echo "##########################################"
echo "##        Identity services             ##"
echo "##########################################"

echo "Installing OpenStack keystone packages..."
yum install -y openstack-keystone python-keystoneclient > /dev/null
echo "Done."

if [ "${DEBUG}" == "ON" ]; then
  openstack-config --set /etc/nova/nova.conf \
  DEFAULT verbose True
fi

openstack-config --set /etc/keystone/keystone.conf \
   database connection mysql://keystone:${KEYSTONE_DBPASS}@controller/keystone

echo "Create keystone database and gain permision..."
KEYSTONE_SQL_FILE=${KEYSTONE_SQL_FILE:-$BASE_DIR/sql_scripts/create_db_keystone.sql}
sed -i "s/KEYSTONE_DBPASS/${KEYSTONE_DBPASS}/g" ${KEYSTONE_SQL_FILE}
mysql -u "root" "-p${MYSQL_PASS}" < ${KEYSTONE_SQL_FILE}
sed -i "s/${KEYSTONE_DBPASS}/KEYSTONE_DBPASS/g" ${KEYSTONE_SQL_FILE}
echo "Done."

echo "Sync keystone configuration to database..."
su -s /bin/sh -c "keystone-manage db_sync" keystone
echo "Done."

echo "Generate token..."
TOKEN=$(openssl rand -hex 10)
echo "Done. Token is: ${TOKEN}"

openstack-config --set /etc/keystone/keystone.conf DEFAULT \
   admin_token ${TOKEN}

keystone-manage pki_setup --keystone-user keystone --keystone-group keystone
chown -R keystone:keystone /etc/keystone/ssl
chmod -R o-rwx /etc/keystone/ssl
echo "Done."

echo "Enable and start keystone service..."
service openstack-keystone start
chkconfig openstack-keystone on
echo "Done."

echo "Crontab schedulling auto flush token hourly..."
(crontab -l -u keystone 2>&1 | grep -q token_flush) || \
echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1' >> /var/spool/cron/keystone
echo "Done."

export OS_SERVICE_TOKEN=${TOKEN}
export OS_SERVICE_ENDPOINT=http://controller:35357/v2.0

echo "Creating admin user, role and tenant..."
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@example.com}
keystone user-create --name=admin --pass=${ADMIN_PASS} --email=${ADMIN_EMAIL}
keystone role-create --name=admin
keystone tenant-create --name=admin --description="Admin Tenant"
keystone user-role-add --user=admin --tenant=admin --role=admin
keystone user-role-add --user=admin --role=_member_ --tenant=admin

echo "Creating demo role, tenant and demo user..."
DEMO_EMAIL=${DEMO_EMAIL:-demo@example.com}
keystone user-create --name=demo --pass=${DEMO_PASS} --email=${DEMO_EMAIL}
keystone tenant-create --name=demo --description="Demo Tenant"
keystone user-role-add --user=demo --role=_member_ --tenant=demo

echo "Creating service tenant..."
keystone tenant-create --name=service --description="Service Tenant"

echo "Create Identity service..."
keystone service-create --name=keystone --type=identity \
  --description="OpenStack Identity"

echo "Create endpoint for Identity service..."
keystone endpoint-create \
  --service-id=$(keystone service-list | awk '/ identity / {print $2}') \
  --publicurl=http://controller:5000/v2.0 \
  --internalurl=http://controller:5000/v2.0 \
  --adminurl=http://controller:35357/v2.0

echo "##########################################"
echo "##########################################"