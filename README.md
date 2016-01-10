#Scripts for installing OpenStack using Docker Engine Virtualization

WARN: This scripts is recommend to use on fresh system environment.

Configurations
---------------------------------------------------------
Configuration file: common/openstack.conf

  Specify password for each module of OpenStack
  Specify ip address of controller and all compute nodes
  Specify network interface name for controller network and compute network (Can be the same network interface)
  Specify git repository of OpenStack (This branch using OpenStack kilo), Nova-Docker and Nova-Docker branch
  
Before you begin installation
----------------------------------------------------------

Update your linux system to the latest kernel version.
Turn off SELinux on compute nodes


Installing
-----------------------------------------------------------

NOTE: You must check all of script files is executable.

Run install-controller.sh on controller node
Run install-compute.sh on all of compute nodes

