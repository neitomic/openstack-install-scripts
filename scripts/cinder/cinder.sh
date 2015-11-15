#!/bin/bash

PARENT_DIR=$( cd `dirname $0`/.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

yum install -y lvm2

systemctl enable lvm2-lvmetad.service
systemctl start lvm2-lvmetad.service

pvcreate /dev/sde1

vgcreate cinder-volumes /dev/sde1

