#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root"
	exit 1
fi

dpkg --status prometheus &> /dev/null

if [ $? -eq 0 ]; then
	echo "prometheus: Already installed"
else
	apt-get install -y prometheus
fi

dpkg --status prometheus-node-exporter &> /dev/null

if [ $? -eq 0 ]; then
	echo "prometheus-node-exporter: Already installed"
else
	apt-get install -y prometheus-node-exporter
fi

dpkg --status prometheus-alertmanager &> /dev/null

if [ $? -eq 0 ]; then
	echo "prometheus-alertmanager: Already installed"
else
	apt-get install -y prometheus-alertmanager
fi

dpkg --status docker.io &> /dev/null

if [ $? -eq 0 ]; then
	echo "docker.io: Already installed"
else
	apt-get install -y docker.io
fi

dpkg --status docker-compose-v2 &> /dev/null
if [ $? -eq 0 ]; then
	echo "docker-compose: Already installed"
else
	apt-get install -y docker-compose-v2
fi

curl -sSL https://raw.githubusercontent.com/B4DCATs/openvpn_exporter/main/quick-start.sh | bash 
