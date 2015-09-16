#!/bin/bash

###########################################
##       Time synchronize service        ##
###########################################

echo "Installing ntp package..."
yum -y install ntp > /dev/null
echo "Done."

echo "Configuring and start ntp service..."
echo 'restrict -4 default kod notrap nomodify' >> /etc/ntp.conf
echo 'restrict -6 default kod notrap nomodify' >> /etc/ntp.conf

systemctl enable ntpd.service > /dev/null
systemctl start ntpd.service > /dev/null
echo "Done."

echo "DONE! Have a good day! :)"