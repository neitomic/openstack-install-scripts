#!/bin/bash
#Qpid used in RHEL-6

echo "Installing QPid..."
yum install -y qpid-cpp-server > /dev/null

QPID_CONF_FILE=/etc/qpidd.conf

grep -q "^auth=" ${QPID_CONF_FILE} && sed "s/^auth=.*/auth=no/" -i ${QPID_CONF_FILE} || 
    sed "$ a\auth=no" -i ${QPID_CONF_FILE}

service qpidd start > /dev/null
chkconfig qpidd on > /dev/null

echo "Done."