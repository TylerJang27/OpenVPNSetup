#!/bin/bash

read netID
read v_m
read -s pass
echo -e "About to ssh"
pwd
/usr/bin/sshpass -p $pass ssh -o StrictHostKeyChecking=no $netID@$v_m echo -e "$netID\n$v_m\n$pass" | curl -Ls https://raw.githubusercontent.com/TylerJang27/OpenVPNSetup/master/inner_script2.sh | /bin/bash
echo "About to ssh"
/usr/bin/sshpass -p $pass ssh -o StrictHostKeyChecking=no $netID@$v_m echo -e "$netID\n$v_m\n$pass" | curl -Ls https://raw.githubusercontent.com/TylerJang27/OpenVPNSetup/master/inner_script3.sh | /bin/bash
