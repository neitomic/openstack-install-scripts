#!/bin/bash
NETWORK_PREFIX=${NETWORK_PREFIX:-172.28.181}
IPADDR=$(ifconfig | grep ${NETWORK_PREFIX} | awk '{print $2}' | awk -F: '{print $2}')
echo ${IPADDR}
