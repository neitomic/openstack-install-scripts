#!/bin/bash
##########################################
##        Database services             ##
##########################################

PARENT_DIR=$( cd `dirname $0`/.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

echo "Install mariadb packages..."
yum install -y mariadb mariadb-server MySQL-python expect > /dev/null
echo "Done."
# sed -i "/\[mysqld\]/a bind-address = ${CONTROLLER_IP}\ndefault-storage-engine = innodb\ninnodb_file_per_table\ncollation-server = utf8_general_ci\ninit-connect = 'SET NAMES utf8'\ncharacter-set-server = utf8" /etc/my.cnf

# systemctl enable mariadb.service
# systemctl start mariadb.service

# ../tools/auto_init_mariadb.sh ${MYSQL_PASS} ${MYSQL_ORIGINAL_PASS}

echo "Configuring and starting mariadb service..."
echo "[mysqld]
bind-address = ${CONTROLLER_IP}
default-storage-engine = innodb
innodb_file_per_table
collation-server = utf8_general_ci
init-connect = 'SET NAMES utf8'
character-set-server = utf8" > /etc/my.cnf.d/mariadb_openstack.cnf

systemctl enable mariadb.service > /dev/null
systemctl start mariadb.service > /dev/null

echo "Done."

echo "Auto initializing mariadb...."
${BASE_DIR}/tools/auto_init_mariadb.sh ${MYSQL_PASS} ${MYSQL_ORIGINAL_PASS}
echo "DONE! Have a good day!"