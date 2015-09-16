#!/bin/bash
##########################################
##        Database services             ##
##########################################

PARENT_DIR=$( cd `dirname $0`/../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

echo "Install mysql packages..."
yum install -y mysql mysql-server MySQL-python expect > /dev/null
echo "Done."

# systemctl enable mysql.service
# systemctl start mysql.service

# ../tools/auto_init_mysql.sh ${MYSQL_PASS} ${MYSQL_ORIGINAL_PASS}

echo "Configuring and starting mysql service..."

sed -i "/\[mysqld\]/a bind-address = ${CONTROLLER_IP}\n\
default-storage-engine = innodb\n\
innodb_file_per_table\n\
collation-server = utf8_general_ci\n\
init-connect = 'SET NAMES utf8'\n\
character-set-server = utf8" /etc/my.cnf


service mysqld start > /dev/null
chkconfig mysqld on > /dev/null

echo "Done."

echo "Auto initializing mysql...."
${BASE_DIR}/tools/auto_init_mysql.sh ${MYSQL_PASS} ${MYSQL_ORIGINAL_PASS}
echo "DONE! Have a good day!"