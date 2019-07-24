#!/bin/bash

read netID
read v_m
read -s pass
echo -e "About to ssh"
pwd
/usr/bin/sshpass -p $pass ssh -o StrictHostKeyChecking=no $netID@$v_m curl -L https://raw.githubusercontent.com/TylerJang27/OpenVPNSetup/master/inner_script2.sh | /bin/bash -s $netID $v_m $pass
echo "About to ssh"

/usr/bin/sshpass -p $pass ssh -o StrictHostKeyChecking=no $netID@$v_m curl -L https://raw.githubusercontent.com/TylerJang27/OpenVPNSetup/master/inner_script3.sh | /bin/bash -s $netID $v_m $pass
