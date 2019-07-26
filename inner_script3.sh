#!/bin/bash
ls
my_ip_now=$(curl ifconfig.me/ip | cut -f1 -d ".")

#netID=$1
#v_m=$2
#pass=$3
echo "please enter your netID"
read netID
echo "please enter your password"
read -s pass

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

	echo "$pass" | sudo systemctl start openvpn@server
	status_1=$(sudo systemctl status openvpn@server)
	status_2=$(ip addr show tun0)
	systemctl enable openvpn@server

	my_ip=$(curl ifconfig.me/ip)

	mkdir -p ~/client-configs/files

	curl -Ls https://raw.githubusercontent.com/TylerJang27/OpenVPNSetup/master/base.conf >> ~/client-configs/base.conf
	found=$(find / -name base.conf)
	if [[ -z "$found" ]]; then
		echo "Error. File not found."
	else
		rm_path="~/client-configs/base.conf"
		rm_line=43
		ad_path="~/client-configs/base.conf"
		ad_line=43
		ad_content="remote $my_ip 1194"
		rem_line
		add_line

		echo "Press enter to continue 9"
		read empty

		curl -Ls https://raw.githubusercontent.com/TylerJang27/OpenVPNSetup/master/make_config.sh >> ~/client-configs/make_config.sh
		########################running?
		chmod 700 ~/client-configs/make_config.sh

		cd ~/client-configs
		./make_config.sh client1

		echo $status_1
		echo $status_2
	fi
else
	echo "Error. You're not in the virtual machine."
fi
