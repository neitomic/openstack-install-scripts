#!/bin/bash

source ../common/openstack.conf

sed -i "s/KEYSTONE_DBPASS/${KEYSTONE_DBPASS}/g" ../sql_scripts/create_db_keystone.sql

mysql -u "root" "-p${PASSWORD}" < ../sql_scripts/create_db_keystone.sql

sed -i "s/${KEYSTONE_DBPASS}/KEYSTONE_DBPASS/g" ../sql_scripts/create_db_keystone.sql
