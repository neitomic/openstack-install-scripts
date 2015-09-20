#!/bin/bash

###########################################
##       Time synchronize service        ##
###########################################

echo "##########################################"
echo "##             NTP services             ##"
echo "##########################################"

echo "Installing ntp package..."
yum -y install ntp > /dev/null
echo "Done."

echo "Configuring and start ntp service..."
echo 'restrict -4 default kod notrap nomodify' >> /etc/ntp.conf
echo 'restrict -6 default kod notrap nomodify' >> /etc/ntp.conf

service ntpd start > /dev/null
chkconfig ntpd on > /dev/null

echo "Done."

echo "DONE! Have a good day! :)"
echo "##########################################"
echo "##########################################"