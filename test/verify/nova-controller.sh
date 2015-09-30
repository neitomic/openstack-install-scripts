#!/bin/bash

PARENT_DIR=$( cd `dirname $0`/../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

echo "##########################################"
echo "###       Verifing nova service        ###"
echo "#----------------------------------------#"

source ${BASE_DIR}/admin-openrc.sh
nova image-list	