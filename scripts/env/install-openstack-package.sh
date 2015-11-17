#!/bin/bash

# echo "Install yum priority plugin..."
# yum install -y yum-plugin-priorities > /dev/null
# echo "Done."

# echo "Install epel repo for RHEL..."
# yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm > /dev/null
# echo "Done."

# subscription-manager repos --enable=rhel-7-server-optional-rpms
# subscription-manager repos --enable=rhel-7-server-extras-rpms

echo "Installing OpenStack repo..."
yum install -y ${OPENSTACK_REPO} > /dev/null
echo "Done."

echo "Upgrade system..."
yum -y upgrade > /dev/null
echo "Done."

# echo "Installing OpenStack SELinux..."
# yum -y install openstack-selinux > /dev/null
# echo "Done."

echo "DONE! Have a good day! :)"