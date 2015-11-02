#!/bin/bash
##########################################
##        Database services             ##
##########################################

PARENT_DIR=$( cd `dirname $0`/../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

echo "Install mariadb packages..."
yum install -y mariadb mariadb-server MySQL-python expect > /dev/null
echo "Done."
sed -i "/\[mysqld\]/a bind-address = ${CONTROLLER_IP}\n\
default-storage-engine = innodb\n\
innodb_file_per_table\n\
collation-server = utf8_general_ci\n\
init-connect = 'SET NAMES utf8'\n\
character-set-server = utf8" /etc/my.cnf

systemctl enable mariadb.service
systemctl start mariadb.service

../tools/auto_init_mariadb.sh ${MYSQL_PASS} ${MYSQL_ORIGINAL_PASS}
echo "Done."

echo "Auto initializing mariadb...."
${BASE_DIR}/tools/auto_init_mariadb.sh ${MYSQL_PASS} ${MYSQL_ORIGINAL_PASS}
echo "DONE! Have a good day!"