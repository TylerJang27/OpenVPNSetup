#!/bin/bash

read netID
read v_m
read -s pass
echo "Press enter to continue 2"
read empty
sshpass -p $pass ssh -o StrictHostChecking=no $netID@$v_m echo -e "$netID\n$v_m\n$pass" | curl -Ls https://raw.githubusercontent.com/TylerJang27/OpenVPNSetup/master/inner_script2.sh | /bin/bash
echo "Press enter to continue 7"
read empty
sshpass -p $pass ssh -o StrictHostChecking=no $netID@$v_m echo -e "$netID\n$v_m\n$pass" | curl -Ls https://raw.githubusercontent.com/TylerJang27/OpenVPNSetup/master/inner_script3.sh | /bin/bash
