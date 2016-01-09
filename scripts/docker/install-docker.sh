#!/bin/bash
PARENT_DIR=$( cd `dirname $0`/../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

yum -y install python-pip git gcc

curl -sSL https://get.docker.com | sh

usermod -aG docker nova

systemctl enable docker
systemctl start docker

cd ${BASE_DIR}

if [[ -n "$NOVA_DOCKER_BRANCH" ]]; then
	git clone -b ${NOVA_DOCKER_BRANCH} ${NOVA_DOCKER_GIT}
else
	git clone ${NOVA_DOCKER_GIT}
fi

cd nova-docker
python setup.py install

mkdir -p /etc/nova/rootwrap.d/
cp etc/nova/rootwrap.d/docker.filters /etc/nova/rootwrap.d/
