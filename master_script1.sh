#!/bin/bash

while IFS=read -r line
do
	netID=$line
done < /www/cyber-pizza/all/assets/settings/net-id.txt

echo -n "Enter your virtual machine (in the format of vcm-#####.vm.duke.edu): "
read v_m
echo "Enter your Duke password:"
echo "This information will not be stored."
read -s pass
echo -n "Thank you. Beginning installation process."

chroot /mnt/mmcblk0p3/ubuntu echo -e "$netID\n$v_m\n$pass" | curl script1
####
exit

echo -e "Preparing to copy configuration file\n"

scp /etc/openvpn/vpnclient1.conf $netID@$v_m:~/client-configs/files/client1.ovpn
service openvpn restart

echo -n "VPN setup complete."




#need to get the scripts and the config files (inner script 3) to curl