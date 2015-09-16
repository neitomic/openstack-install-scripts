#!/bin/bash

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
systemctl enable ntpd.service
systemctl start ntpd.service

echo "DONE! Have a good day! :)"