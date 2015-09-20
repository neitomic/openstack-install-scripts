#!/bin/bash

echo "##########################################"
echo "##             NTP services             ##"
echo "##########################################"
echo "Installing ntp package..."
yum -y install ntp > /dev/null
echo "Done."

#Remove all server
echo "Remove all default time servers..."
sed -i '/server/ s/^/#/' /etc/ntp.conf

#Add controller server
echo "Add controller server..."
sed -i "/# Please consider joining the pool/a server controller iburst" /etc/ntp.conf

echo "Enable and start ntp service..."
service ntpd start > /dev/null
chkconfig ntpd on > /dev/null

echo "DONE! Have a good day! :)"
echo "##########################################"
echo "##########################################"