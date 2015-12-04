#!/bin/bash
NETWORK_PREFIX=${NETWORK_PREFIX:-10.0.2}
IPADDR=$(ifconfig | grep ${NETWORK_PREFIX} | awk '{print $2}')
echo ${IPADDR}
