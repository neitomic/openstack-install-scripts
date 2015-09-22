#!/bin/bash

PARENT_DIR=$( cd `dirname $0`/../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

echo "##########################################"
echo "###     Verifing keystone service      ###"
echo "#----------------------------------------#"

yum -y install wget > /dev/null

mkdir /tmp/images
cd /tmp/images/
wget http://download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img

source admin-openrc.sh

glance image-create --name "cirros-0.3.2-x86_64" --disk-format qcow2 \
  --container-format bare --is-public True --progress < cirros-0.3.2-x86_64-disk.img

glance image-list

rm -r /tmp/images

cd ${BASE_DIR}

echo "#----------------------------------------------#"
echo "################################################"