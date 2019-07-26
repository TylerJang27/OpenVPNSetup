#!/bin/bash

my_ip_now=$(curl ifconfig.me/ip | cut -f1 -d ".")
echo $my_ip_now
my_ip=$(curl ifconfig.me/ip)
echo $my_ip

echo "Please enter your netID"
read netID

uncomment() { #uses uc_path and uc_line to remove the first character of a line
	touch /temp.txt
	local uc_line_less=$(($uc_line-1))
	local uc_line_more=$(($uc_line+1))
	cat $uc_path | head -n $uc_line_less >> /temp.txt
	cat $uc_path | head -n $uc_line | tail -n 1 | cut -f2 -d ";" >> /temp.txt
	cat $uc_path | tail -n +$uc_line_more >> /temp.txt
	mv /temp.txt $uc_path
}

ad_path="/"
ad_line=1
ad_content=""

add_line() {
	touch /temp.txt
	local ad_line_less=$(($uc_line-1))
	cat $ad_path | head -n $ad_line_less >> /temp.txt
	echo -e $ad_content >> temp.txt
	cat $ad_path | tail -n +$ad_line >> /temp.txt
	mv /temp.txt $ad_path
}

rm_path="/"
rm_line=1

rem_line() {
	touch /temp.txt
	local rm_line_less=$(($rm_line-1))
	local rm_line_more=$(($rm_line+1))
	cat $rm_path | head -n $rm_line_less >> /temp.txt
	cat $rm_path | tail -n +$rm_line_more >> /temp.txt
	mv /temp.txt $rm_path
}

if [[ $my_ip_now == "67" ]]; then
	echo -n "You have SSHed into your virtual machine."

	apt update
	apt install net-tools
	
	echo "y" | apt install openvpn
	wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.6/EasyRSA-unix-v3.0.6.tgz

	found=$(find / -name EasyRSA-unix-v3.0.6.tgz)
	if [[ -z "$found" ]]; then
		echo "Error. File not found."
	else
		tar xvf ~/EasyRSA-unix-v3.0.6.tgz
		
		cd /home/
		ls | cut -f1 -d " " >> temp.txt
		
		while IFS= read -r line
			do if [[ "$line" != "rapid" ]] && [[ "$line" != "vcm" ]] && [[ "$line" != "temp.txt" ]]; then
				netID=$(echo "$line" | xargs)
			fi
		echo $netID
		done < /temp.txt
		
		mv /home/$netID/EasyRSA-v3.0.6 ~/EasyRSA-v3.0.6
		cd ~/EasyRSA-v3.0.6/
				#cp vars.example vars
				#nano vars
		touch vars
		cat vars.example | head -n 90 >> vars
		echo -e "set_var EASYRSA_REQ_COUNTRY\t\"US\"\nset_var EASYRSA_REQ_PROVINCE\t\"North Carolina\"\nset_var EASYRSA_REQ_CITY\t\"Durham\"\nset_var EASYRSA_REQ_ORG\t\"Duke University\"\nset_var EASYRSA_REQ_EMAIL\t\"$netID@duke.edu\"\nset_var EASYRSA_REQ_OU\t\"Guardian Devil\"">>vars
		cat vars.example | tail -n +97 >> vars
		
		bash ./easyrsa init-pki
		echo -e "\n" | ./easyrsa build-ca nopass
				##
				##
		echo -e "\n" | ./easyrsa gen-req server nopass
				##
				##
		cp ~/EasyRSA-v3.0.6/pki/private/server.key /etc/openvpn/
		echo -e "yes" | ./easyrsa sign-req server server
				##
				##
		cp ~/EasyRSA-v3.0.6/pki/issued/server.crt /etc/openvpn/
		cp ~/EasyRSA-v3.0.6/pki/ca.crt /etc/openvpn/
		
		./easyrsa gen-dh
		openvpn --genkey --secret ta.key
		cp ~/EasyRSA-v3.0.6/ta.key /etc/openvpn/
		cp ~/EasyRSA-v3.0.6/pki/dh.pem /etc/openvpn/
		mkdir -p ~/client-configs/keys
		chmod -R 700 ~/client-configs
		echo -e "\n" | ./easyrsa gen-req client1 nopass
				#
				#
		cp pki/private/client1.key ~/client-configs/keys/
		./easyrsa import-req ~/EasyRSA-v3.0.6/pki/reqs/client1.req client1
		echo -e "yes" | ./easyrsa sign-req client client1
				#
				#
		cp ~/EasyRSA-v3.0.6/pki/issued/client1.crt ~/client-configs/keys/
				##
		cp ~/EasyRSA-v3.0.6/ta.key ~/client-configs/keys/
		cp /etc/openvpn/ca.crt ~/client-configs/keys/
		cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
		gzip -d /etc/openvpn/server.conf.gz
		
		touch /etc/openvpn/server_temp.conf
		curl -L https://raw.githubusercontent.com/TylerJang27/OpenVPNSetup/master/server.conf >> /etc/openvpn/server_temp.conf
		mv /etc/openvpn/server_temp.conf /etc/openvpn/server.conf
		sleep 2
		cat /etc/openvpn/server.conf
		sleep 2
		
		touch /etc/sysctl_temp.conf
		curl -L https://raw.githubusercontent.com/TylerJang27/OpenVPNSetup/master/sysctl.conf >> /etc/sysctl.conf
		mv /etc/sysctl_temp.conf /etc/sysctl.conf
		
		sysctl -p
		apt-get install ufw

		touch /etc/default/ufw_temp
		curl -L https://raw.githubusercontent.com/TylerJang27/OpenVPNSetup/master/default_ufw.txt >> /etc/default/ufw_temp
		mv /etc/default/ufw_temp /etc/default/ufw
		#echo -e "# START OPENVPN RULES\n# NAT table rules\n*nat\n:POSTROUTING ACCEPT [0:0]\n# Allow traffic from OpenVPN client to eth0\n-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE\nCOMMIT\n# END OPENVPN RULES" >> /etc/ufw/before.rules

		touch /etc/ufw/before_temp.rules
		curl -L https://raw.githubusercontent.com/TylerJang27/OpenVPNSetup/master/before.rules.txt >> /etc/ufw/before_temp.rules
		mv /etc/ufw/before_temp.rules /etc/ufw/before.rules
		
		touch /etc/ufw/before_temp.rules
		cat /etc/ufw/before.rules | head -n 21 >> /etc/ufw/before_temp.rules
		echo -e "-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE\nCOMMIT" >> /etc/ufw/before_temp.rules
		cat /etc/ufw/before.rules | tail -n +23 >> /etc/ufw/before_temp.rules
		mv /etc/ufw/before_temp.rules /etc/ufw/before.rules
		
		ufw allow 1194/udp
		ufw allow OpenSSH
		ufw disable
		ufw enable
		exit
		exit
	fi
else
	echo "Error. You're not in the virtual machine."
fi
