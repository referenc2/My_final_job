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

cp -rf /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/server/

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

systemctl enable openvpn-server@server.service
systemctl start openvpn-server@server.service

echo "Configuring base.conf"

cp -rf /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/client/base.conf

read -p "Enter your ip address to connect the client: " IP_SERVER

sed -i 's/remote my-server-1 1194/remote '$IP_SERVER' 1994/' /etc/openvpn/client/base.conf
sed -ie 's/;user nobody/user nobody/
s/;group nobody/group nobody/
s/ca ca.crt/;ca ca.crt/
s/cert client.crt/;cert client.crt/
s/key client.key/;key client.key/
s/;tls-crypt ta.key 1/tls-crypt ta.key 1/
/cipher AES-256-CBC/a\auth SHA256
/cipher AES-256-CBC/a\cipher AES-256-GCM
s/cipher AES-256-CBC/;cipher AES-256-CBC/
$a\key-direction 1
$a\; script-security 2
$a\; up /etc/openvpn/update-resolv-conf
$a\; down /etc/openvpn/update-resolv-conf
' /etc/openvpn/client/base.conf

echo "Creating a file make_config.sh"
BASE='${BASE_CONFIG}'
KEY='${KEY_DIR}'
OUTPUT='${OUTPUT_DIR}'
ID='${1}'

cat << EOF > /etc/openvpn/client/make_config.sh
#!/bin/bash
# First argument: Client identifier
KEY_DIR=./
OUTPUT_DIR=./
BASE_CONFIG=./base.conf
cat ${BASE} \
<(echo -e '<ca>') \
${KEY}/ca.crt \
<(echo -e '</ca>\n<cert>') \
${KEY}/${ID}.crt \
<(echo -e '</cert>\n<key>') \
${KEY}/${ID}.key \
<(echo -e '</key>\n<tls-crypt>') \
${KEY}/ta.key \
<(echo -e '</tls-crypt>') \
> ${OUTPUT}/${ID}.ovpn
EOF

chmod +x /etc/openvpn/client/make_config.sh

echo "To finish configuring the client file, run script make_config.sh in /etc/openvpn/client/ with client identifier"
