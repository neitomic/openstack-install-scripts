#!/bin/bash

source ../common/openstack.conf

echo ${PASSWORD}
echo ${MYSQL_PASS}
echo ${CONTROLLER_IP}

echo "Print variable in second level:"
./second-level.sh