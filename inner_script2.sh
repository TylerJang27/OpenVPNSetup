#!/bin/bash
ls
curl ifconfig.me/ip

netID=$1
v_m=$2
pass=$3
#read netID
#read v_m
#read -s pass

uncomment() { #uses uc_path and uc_line to remove the first character of a line
	touch temp.txt
	local uc_line_less=$(($uc_line-1))
	local uc_line_more=$(($uc_line+1))
	cat $uc_path | head -n $uc_line_less >> temp.txt
	cat $uc_path | head -n $uc_line | tail -n 1 | cut -f2 -d ";" >> temp.txt
	cat $uc_path | tail -n +$uc_line_more >> temp.txt
	sudo mv temp.txt $uc_path
		##sudo?
}

ad_path="/"
ad_line=1
ad_content=""

add_line() {
	touch temp.txt
	local ad_line_less=$(($uc_line-1))
	cat $ad_path | head -n $ad_line_less >> temp.txt
	echo -e $ad_content >> temp.txt
	cat $ad_path | tail -n +$ad_line >> temp.txt
	sudo mv temp.txt $ad_path
		##sudo?
}

rm_path="/"
rm_line=1

rem_line() {
	touch temp.txt
	local rm_line_less=$(($rm_line-1))
	local rm_line_more=$(($rm_line+1))
	cat $rm_path | head -n $rm_line_less >> temp.txt
	cat $rm_path | tail -n +$rm_line_more >> temp.txt
	sudo mv temp.txt $rm_path
		##sudo?
}

echo -n "You have SSHed into your virtual machine."

echo "$pass" | sudo apt update
echo "y" | sudo apt install openvpn
wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.6/EasyRSA-unix-v3.0.6.tgz

found=$(find / -name EasyRSA-unix-v3.0.6.tgz)
if [[ -z "$found" ]]; then
	echo "Error. File not found."
else
	tar xvf EasyRSA-unix-v3.0.6.tgz
	cd ~/EasyRSA-v3.0.6/
			#cp vars.example vars
			#nano vars
	touch vars
	cat vars.example | head -n 90 >> vars
	echo -e "set_var EASYRSA_REQ_COUNTRY\t\"US\"\nset_var EASYRSA_REQ_PROVINCE\t\"North Carolina\"\nset_var EASYRSA_REQ_CITY\t\"Durham\"\nset_var EASYRSA_REQ_ORG\t\"Duke University\"\nset_var EASYRSA_REQ_EMAIL\t\"$netID@duke.edu\"\nset_var EASYRSA_REQ_OU\t\"Guardian Devil\"">>vars
	cat vars.example | tail -n +97 >> vars
	
	echo "Press enter to continue 4"
	read empty
	
	bash ./easyrsa init-pki
	echo -e "\n" | ./easyrsa build-ca nopass
			##
			##
	echo -e "\n" | ./easyrsa gen-req server nopass
			##
			##
	sudo cp ~/EasyRSA-v3.0.6/pki/private/server.key /etc/openvpn/
	echo -e "yes" | ./easyrsa sign-req server server
			##
			##
	sudo cp ~/EasyRSA-v3.0.6/pki/issued/server.crt /etc/openvpn/
	sudo cp ~/EasyRSA-v3.0.6/pki/ca.crt /etc/openvpn/
	
	echo "Press enter to continue 5"
	read empty
	
	./easyrsa gen-dh
	openvpn --genkey --secret ta.key
	sudo cp ~/EasyRSA-v3.0.6/ta.key /etc/openvpn/
	sudo cp ~/EasyRSA-v3.0.6/pki/dh.pem /etc/openvpn/
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
	sudo cp /etc/openvpn/ca.crt ~/client-configs/keys/
	sudo cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
	sudo gzip -d /etc/openvpn/server.conf.gz

	echo "Press enter to continue 6"
	read empty
	
	uc_path="/etc/openvpn/server.conf"
	uc_line=244
	ad_path="/etc/openvpn/server.conf"
	ad_line=245
	ad_content="key-direction 0"
	#uncomment
	add_line

	ad_line=254
	ad_content="auth SHA256"
	add_line

	rm_path="/etc/openvpn/server.conf"
	rm_line=85
	ad_line=85
	ad_content="dh dh.pem"
	rem_line
	add_line
	uc_line=276
	uncomment
	uc_line=277
	uncomment
	uc_line=192
	uncomment
	rm_line=200
	ad_line=200
	ad_content="push \"dhcp-option DNS 152.3.72.100\""
	rem_line
	add_line
	rm_line=201
	ad_line=201
	ad_content="push \"dhcp-option DNS 152.3.70.100\""
	rem_line
	add_line

	uc_path="/etc/sysctl.conf"
	uc_line=28
	uncomment

	sudo sysctl -p
	sudo apt-get install ufw

	ad_path="/etc/ufw/before.rules"
	ad_line=18
	ad_content="# START OPENVPN RULES\n# NAT table rules\n*nat\n:POSTROUTING ACCEPT [0:0]\n# Allow traffic from OpenVPN client to eth0\n-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE\nCOMMIT\n# END OPENVPN RULES"
	add_line
	rm_path="/etc/default/ufw"
	rm_line=19
	ad_path="/etc/default/ufw"
	ad_line=19
	ad_content="DEFAULT_FORWARD_POLICY=\"ACCEPT\""
	rem_line
	add_line

	sudo ufw allow 1194/udp
	sudo ufw allow OpenSSH
	sudo ufw disable
	echo "y" | sudo ufw enable
fi
