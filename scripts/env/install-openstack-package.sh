#!/bin/bash

echo "##########################################"
echo "##        OpenStack packages            ##"
echo "##########################################"


echo "Install yum priority plugin..."
yum install -y yum-plugin-priorities > /dev/null
echo "Done."

echo "Installing OpenStack repo..."
yum install -y ${OPENSTACK_REPO} > /dev/null

OPENSTACK_REPO_BASE_URL=${OPENSTACK_REPO_BASE_URL:-https://repos.fedorapeople.org/repos/openstack/EOL/openstack-icehouse/epel-6/}

sed -i "s,^baseurl=.*,baseurl=${OPENSTACK_REPO_BASE_URL}," /etc/yum.repos.d/rdo-release.repo

echo "Done."

echo "Install epel repo for CentOs..."
yum install -y http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm > /dev/null
echo "Done."

echo "Installing OpenStack Utils..."
yum install -y openstack-utils > /dev/null
echo "Done."

echo "Installing OpenStack SELinux..."
yum -y install openstack-selinux > /dev/null
echo "Done."

echo "Upgrade system..."
yum -y upgrade > /dev/null
echo "Done."

echo "DONE! Have a good day! :)"
echo "##########################################"
echo "##########################################"