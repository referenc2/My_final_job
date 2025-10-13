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

Конфигурацию внутри файлов в незапакованном deb-пакете можно посмотреть [здесь](https://github.com/referenc2/My_final_job/tree/main/task_1/easy-rsa-config-0.1/debian)

# Задание 2

Был создан скрипт ___script_for_vpn.sh___ для настройки впн сервера.

Шаги, которые он выполняет:

* Проверка установлен ли openvpn, в случае отсутствия установка.
* Настройка server.conf.
* Настройка base.conf.
* Создание скрипта make_config.sh для объединения нужных файлов.

Посмотреть содержимое скрипта можно [здесь](https://github.com/referenc2/My_final_job/blob/main/task_2/script_for_vpn.sh)

Была измененена структура папок в репозитории для более удобного пользования.

После скрипта был создан deb-пакет для установки необходимых конфигурационных файлов для openvpn.
Список конфигурацонных файлов в deb-пакете:

* ca.crt
* client-1.ovpn
* server.conf
* server.crt
* server.key
* ta.key

Посмотреть содержимое deb-пакета можно [здесь](https://github.com/referenc2/My_final_job/tree/main/task_2/config-for-openvpn-0.1)

# Задание 3

Был создан скрипт ___script_for_metrics.sh___ для установки и начальной настройки prometheus и его экспортеров. Он устанавливает openvpn экспортер, если установлен openvpn. [Ссылка на содержимое скрипта](https://github.com/referenc2/My_final_job/blob/main/task_3/script_for_metrics.sh)

Был создан deb-пакет для установки конфигурационных файлов для prometheus. [Ссылка на содержимое deb-пакета](https://github.com/referenc2/My_final_job/tree/main/task_3/config-for-prometheus-1.1)

# Задание 4

Был написан документ с вероятными сценариями отказа и действиями для их устранения.

Был изменен deb-пакет для конфигурационных файлов prometheus. [Содержимое deb-пакета](https://github.com/referenc2/My_final_job/tree/main/task_4/config-for-prometheus-1.1)
