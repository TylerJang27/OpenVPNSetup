#!/bin/bash

	echo -e "Preparing to copy configuration file\n"

	scp /etc/openvpn/vpnclient1.conf $netID@$v_m:~/client-configs/files/client1.ovpn
	service openvpn restart

	echo "VPN setup complete."