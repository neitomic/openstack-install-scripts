#!/bin/bash

PARENT_DIR=$( cd `dirname $0`/.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

echo "Create keystone database and gain permision..."
KEYSTONE_SQL_FILE=${KEYSTONE_SQL_FILE:-$BASE_DIR/sql_scripts/create_db_keystone.sql}
sed -i "s/KEYSTONE_DBPASS/${KEYSTONE_DBPASS}/g" ${KEYSTONE_SQL_FILE}
mysql -u "root" "-p${MYSQL_PASS}" < ${KEYSTONE_SQL_FILE}
sed -i "s/${KEYSTONE_DBPASS}/KEYSTONE_DBPASS/g" ${KEYSTONE_SQL_FILE}
echo "Done."

echo "Generate token..."
TOKEN=$(openssl rand -hex 10)
echo "Done. Token is: ${TOKEN}"

echo "Installing OpenStack keystone packages..."
yum install -y openstack-keystone httpd mod_wsgi python-openstackclient memcached python-memcached > /dev/null
echo "Done."

echo "Enable and start memcached service..."
systemctl enable memcached.service > /dev/null
systemctl start memcached.service > /dev/null
echo "Done."

echo "Adding keystone configuration..."
sed -i "/^\[DEFAULT\]$/a admin_token = ${TOKEN}" /etc/keystone/keystone.conf
sed -i "/^\[database\]$/a connection = mysql://keystone:${KEYSTONE_DBPASS}@controller/keystone" /etc/keystone/keystone.conf
sed -i "/^\[memcache\]$/a servers = localhost:11211" /etc/keystone/keystone.conf
sed -i "/^\[token\]$/a provider = keystone.token.providers.uuid.Provider\ndriver = keystone.token.persistence.backends.memcache.Token" /etc/keystone/keystone.conf
sed -i "/^\[revoke\]$/a driver = keystone.contrib.revoke.backends.sql.Revoke" /etc/keystone/keystone.conf
echo "Done."
# The old one. For juno install
# keystone-manage pki_setup --keystone-user keystone --keystone-group keystone
# chown -R keystone:keystone /var/log/keystone
# chown -R keystone:keystone /etc/keystone/ssl
# chmod -R o-rwx /etc/keystone/ssl
# su -s /bin/sh -c "keystone-manage db_sync" keystone

# systemctl enable openstack-keystone.service
# systemctl start openstack-keystone.service

# (crontab -l -u keystone 2>&1 | grep -q token_flush) || \
#   echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1' \
#   >> /var/spool/cron/keystone

################################################
# The new one. For Kilo install

echo "Sync keystone configuration to database..."

su -s /bin/sh -c "keystone-manage db_sync" keystone
echo "Done."

#############################################################
##           To configure the Apache HTTP server           ##
#############################################################

echo "Configuring Apache HTTP server..."

sed -i "/^#ServerName www.example.com:80$/a ServerName controller" /etc/httpd/conf/httpd.conf

echo "Listen 5000
Listen 35357

<VirtualHost *:5000>
    WSGIDaemonProcess keystone-public processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-public
    WSGIScriptAlias / /var/www/cgi-bin/keystone/main
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    LogLevel info
    ErrorLogFormat \"%{cu}t %M\"
    ErrorLog /var/log/httpd/keystone-error.log
    CustomLog /var/log/httpd/keystone-access.log combined
</VirtualHost>

<VirtualHost *:35357>
    WSGIDaemonProcess keystone-admin processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-admin
    WSGIScriptAlias / /var/www/cgi-bin/keystone/admin
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    LogLevel info
    ErrorLogFormat \"%{cu}t %M\"
    ErrorLog /var/log/httpd/keystone-error.log
    CustomLog /var/log/httpd/keystone-access.log combined
</VirtualHost>" > /etc/httpd/conf.d/wsgi-keystone.conf

mkdir -p /var/www/cgi-bin/keystone > /dev/null

curl http://git.openstack.org/cgit/openstack/keystone/plain/httpd/keystone.py?h=stable/kilo \
  | tee /var/www/cgi-bin/keystone/main /var/www/cgi-bin/keystone/admin > /dev/null

chown -R keystone:keystone /var/www/cgi-bin/keystone > /dev/null
chmod 755 /var/www/cgi-bin/keystone/* > /dev/null

echo "Done."

echo "Enable and start httpd service..."
systemctl enable httpd.service
systemctl start httpd.service
echo "Done."



export OS_TOKEN=${TOKEN}
export OS_URL=http://controller:35357/v2.0

echo "Create Identity service..."
openstack service create \
  --name keystone --description "OpenStack Identity" identity

echo "Create endpoint for Identity service..."
openstack endpoint create \
  --publicurl http://controller:5000/v2.0 \
  --internalurl http://controller:5000/v2.0 \
  --adminurl http://controller:35357/v2.0 \
  --region RegionOne \
  identity

echo "Create admin project..."
openstack project create --description "Admin Project" admin

echo "Create user and role for administrator..."
openstack user create --password ${ADMIN_PASS} admin
openstack role create admin
openstack role add --project admin --user admin admin
echo "Done."

echo "Create service project..."
openstack project create --description "Service Project" service

echo "Create demo project..."
openstack project create --description "Demo Project" demo

echo "Create user and role for demo user..."
openstack user create --password ${DEMO_PASS} demo
openstack role create user
openstack role add --project demo --user demo user




# keystone tenant-create --name admin --description "Admin Tenant"
# keystone user-create --name admin --pass ${ADMIN_PASS} --email ${EMAIL_ADDRESS}
# keystone role-create --name admin
# keystone user-role-add --user admin --tenant admin --role admin

# keystone tenant-create --name demo --description "Demo Tenant"
# keystone user-create --name demo --tenant demo --pass ${DEMO_PASS} --email ${EMAIL_ADDRESS}

# keystone tenant-create --name service --description "Service Tenant"


# keystone service-create --name keystone --type identity \
#   --description "OpenStack Identity"

# keystone endpoint-create \
#   --service-id $(keystone service-list | awk '/ identity / {print $2}') \
#   --publicurl http://controller:5000/v2.0 \
#   --internalurl http://controller:5000/v2.0 \
#   --adminurl http://controller:35357/v2.0 \
#   --region regionOne