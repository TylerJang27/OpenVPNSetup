#!/bin/bash
while IFS= read -r line
do
	netID=$line
done < /www/cyber-pizza/all/assets/settings/net-id.txt
#done < temp_net.txt

while IFS= read -r line
do
	v_m=$line
done < /www/cyber-pizza/all/assets/settings/v_m.txt

while IFS= read -r line
do
	pass=$line
done < /www/cyber-pizza/all/assets/settings/pass_temp.txt
cp /etc/backups/empty /www/cyber-pizza/all/assets/settings/pass_temp.txt

#echo -n "Enter your virtual machine number (the # within in the format of vcm-#####.vm.duke.edu): "
#read v_m
#echo "Enter your Duke password. This information will not be stored:"
#read -s pass
#echo -n "Thank you. Beginning installation process."

echo "proceeding to chroot"
#chroot /mnt/mmcblk0p3/ubuntu /bin/bash
chroot ubuntu /bin/bash

chroot_checker=$(find / -name ubuntu_chroot 2>/dev/null)
if [[ -z $"chroot_checker" ]]; then

	curl -L https://raw.githubusercontent.com/TylerJang27/OpenVPNSetup/master/inner_script1.sh | /bin/bash
	####

	echo "done with chroot"
	exit

	echo -e "Preparing to copy configuration file\n"

	scp /etc/openvpn/vpnclient1.conf $netID@$v_m:~/client-configs/files/client1.ovpn
	service openvpn restart

	echo "VPN setup complete."
else
	echo "you're not in the chroot"
fi
	
#to run this script, execute the following command: curl -L https://raw.githubusercontent.com/TylerJang27/OpenVPNSetup/master/master_script1.sh | /bin/bash
