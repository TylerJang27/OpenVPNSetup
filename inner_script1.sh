#!/bin/bash

read netID
read v_m
read -s pass

sshpass -p $pass ssh -o StrictHostChecking=no $netID@$v_m echo -e "$netID\n$v_m\n$pass" | curl script2
######################figure out script2

sshpass -p $pass ssh -o StrictHostChecking=no $netID@$v_m echo -e "$netID\n$v_m\n$pass" | curl script3
######################figure out script3