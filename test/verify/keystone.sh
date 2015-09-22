#!/bin/bash

PARENT_DIR=$( cd `dirname $0`/../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

echo "##########################################"
echo "###     Verifing keystone service      ###"
echo "#----------------------------------------#"

unset OS_SERVICE_TOKEN OS_SERVICE_ENDPOINT

echo "Verify with password"
keystone --os-username=admin --os-password=${ADMIN_PASS} \
  --os-auth-url=http://controller:35357/v2.0 token-get

keystone --os-username=admin --os-password=${ADMIN_PASS} \
  --os-tenant-name=admin --os-auth-url=http://controller:35357/v2.0 \
  token-get

echo "Verify with openrc script"
source ${BASE_DIR}/admin-openrc.sh
keystone token-get
keystone user-list
keystone user-role-list --user admin --tenant admin

echo "Done!"