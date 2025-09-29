# My_final_job
Тут я буду выкладывать свои сделанные задания для финальной работы. По мере выполнения заданий я буду дополнять репозиторий.
# Задание 1
В ходе выполнения задания был создан скрипт ___script.sh___ для настройки удостоверяющего центра и корневого скрипта.

Содержание скрипта:

```
#!/bin/bash

set -e

CA_DIR="./easy-rsa"

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root"
	exit 1
fi

if ! command -v easyrsa &> /dev/null; then
	echo "Установка Easy-RSA..."
	apt-get update
	apt-get install -y easy-rsa
else
	echo "Easy-RSA уже установлен"
fi

if [ -d "$CA_DIR" ]; then 
	echo "$CA_DIR exist"
else
	echo "$CA_DIR doesn't exist"
	mkdir $CA_DIR && echo "$CA_DIR directory has been created"
fi

ln -s /usr/share/easy-rsa/* ./easy-rsa/

chmod 700 $CA_DIR

cd $CA_DIR

./easyrsa init-pki

cat > "./vars" << EOF
set_var EASYRSA_REQ_COUNTRY    "Russia"
set_var EASYRSA_REQ_PROVINCE   "MO"
set_var EASYRSA_REQ_CITY       "Moscow"
set_var EASYRSA_REQ_ORG        "OOO Nice"
set_var EASYRSA_REQ_EMAIL      "Admin@local"
set_var EASYRSA_REQ_OU         "IT"
set_var EASYRSA_ALGO           "ec"
set_var EASYRSA_DIGEST         "sha256"
set_var EASYRSA_REQ_CN          "My Root CA"
set_var EASYRSA_BATCH           "1"
EOF

chmod 600 "./vars"

export EASYRSA_BATCH=1
./easyrsa build-ca nopass

if [ -f "./pki/ca.crt" ] && [ -f "./pki/private/ca.key" ]; then
	echo "The root CA certificate was created successfully"
	chmod 644 ./pki/ca.crt
	chmod 600 ./pki/private/ca.key
else
	echo "Error when creating the root certificate"
	exit 1
fi
```

___Стоит отметить, скрипт лучше всего запускать в домашней директориии пользователя.___

Далее был создан deb-пакет для передачи важных конфигурационных файлов таких как:

* ca.crt
* ca.key
* vars

Конфигурацию внутри файлов в незапакованном deb-пакете можно посмотреть [здесь](https://github.com/referenc2/My_final_job/tree/main/easy-rsa-config-0.1/debian)
