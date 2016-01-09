#!/bin/bash
INTF=$1
IPADDR=$(ip addr | grep inet | grep ${INTF} | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
echo ${IPADDR}
