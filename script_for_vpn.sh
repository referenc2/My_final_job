#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root"
	exit 1
fi

dpkg --status openvpn &> /dev/null

if [ $? -eq 0 ]; then
	echo "openvpn: Already installed"
else
	sudo apt-get install -y openvpn
fi

echo "Configuring server.conf..."

cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/server/

sed -ie '/tls-auth ta.key 0/a\tls-crypt ta.key 
s/tls-auth ta.key 0/;tls-auth ta.key 0/
/cipher AES-256-CBC/a\auth SHA256
/cipher AES-256-CBC/a\cipher AES-256-GCM
s/cipher AES-256-CBC/;cipher AES-256-CBC/
/dh dh2048.pem/a\dh none
s/dh dh2048.pem/;dh dh2048.pem/
s/;user nobody/user nobody/
s/;group nobody/group nobody/' /etc/openvpn/server/server.conf

echo "Configuring sysctl.conf"

sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

systemctl -f enable openvpn-server@server.service
systemctl start openvpn-server@server.service

if [ -d "/etc/openvpn/client/"]
	echo "Configuring sysctl.conf"
	cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf etc/openvpn/client/base.conf
	
	

