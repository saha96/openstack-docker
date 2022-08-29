#!/bin/bash

# **postboot.sh**
# After the server boots, this script ensures that the openstack services work.

#find all services
find /etc/systemd/system/ -name "devstack*" -type f -exec basename {} \; > /tmp/services_list

#enable and create symlink
sudo awk '{print "sudo systemctl enable "$0}' /tmp/services_list > /tmp/services_enable
sudo chmod +x /tmp/services_enable
/tmp/services_enable

#start services
sudo awk '{print "sudo systemctl start "$0}' /tmp/services_list > /tmp/services_start
sudo chmod +x /tmp/services_start
/tmp/services_start

#delete temp files
sudo rm -f /tmp/services*