#!/bin/bash

#to run this script, execute the following command: curl -L https://raw.githubusercontent.com/TylerJang27/OpenVPNSetup/master/master_script1.sh | /bin/bash

while IFS= read -r line
do
	netID=$line
done < /www/cyber-pizza/all/assets/settings/net-id.txt

echo -n "Enter your virtual machine (in the format of vcm-#####.vm.duke.edu): "
read v_m
echo "Enter your Duke password:"
echo "This information will not be stored."
read -s pass
echo -n "Thank you. Beginning installation process."


echo "Press enter to continue 1"
read empty

chroot /mnt/mmcblk0p3/ubuntu echo -e "$netID\n$v_m\n$pass" | curl -Ls https://raw.githubusercontent.com/TylerJang27/OpenVPNSetup/master/master_script1.sh | /bin/bash
####
exit

echo -e "Preparing to copy configuration file\n"

scp /etc/openvpn/vpnclient1.conf $netID@$v_m:~/client-configs/files/client1.ovpn
service openvpn restart

echo -n "VPN setup complete."