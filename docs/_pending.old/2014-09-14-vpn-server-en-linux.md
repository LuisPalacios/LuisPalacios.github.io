---
title: "OpenVPN Server en Linux"
date: "2014-09-14"
categories: apuntes
tags: macosx peakhour snmp
excerpt_separator: <!--more-->
---

![OpenVPN](/assets/img/original/){: width="730px" padding:10px }** que sigue siendo la mejor solución hoy en día, a pesar de que es más complejo de implementar. El objetivo es poder tener acceso a los servicios internos de mi red casera desde internet.

  ![bvSrAN5aY53Ewcw9SKU4ovo6qI7mu4nlR9GiAFqsWSG0FCzNr2BL4vtRAk0nLMB2qAg=w300](/assets/img/original/bvSrAN5aY53Ewcw9SKU4ovo6qI7mu4nlR9GiAFqsWSG0FCzNr2BL4vtRAk0nLMB2qAgw300.png){: width="730px" padding:10px }  

- OpenVPN es la mejor solución VPN a día de hoy. Es fiable, rápido y lo más importante, muy seguro, incluso contra organismos que dicen comprometieron otros protocolos. Como contrapartida, su configuración es más compleja y tiene el inconveniente de necesitar un software adicional en los clientes.
- IKEv2 también es un protocolo rápido y seguro si se usa la implementación open source. Para lo usuarios móviles tiene la ventaja (sobre openvpn) de reconectarse. Es la única solución para usuarios de Blackberry.
- SSTP ofrece las mismas ventajas que OpenVPN pero solo para entornos Windows así que a olvidarse, creado por Microsoft y propietario.
- PPTP es muy **inseguro**, incluso Microsoft que participó en su desarrollo, lo ha abandonado. Tiene la ventaja de que es muy fácil de implementar y tiene compatibildiad en varias plataformas pero deberías evitarlo, una alternativa rápida es el siguiente: L2PT/IPsec mismas ventajas pero más seguro.
- L2TP/IPsec es una buena solucíon VPN para darle un uso no crítico y un montaje rápido sin software adicional, pero ojo! se comenta en los mentideros que también ha sido comprometido.
    

 

# Servidor

## Instalación del Software

# emerge -v app-crypt/easy-rsa

net-misc/openvpn      lzo -pam plugins ssl systemd iproute2 examples

# emerge -v openvpn

 

## Infraestructura PKI

Es la primera vez que instalo openvpn así que necesito crear mi propia infraestructura PKI desde el principio. PKI significa Public Key Infrastructure y es el conjunto de recursos necesarios para crear certificados digitales. Dejo [aquí](http://sobrebits.com/montar-un-servidor-casero-con-raspberry-pi-parte-7-instalacion-y-configuracion-de-openvpn/) y ![aquí](/assets/img/original/Create_a_Public_Key_Infrastructure_Using_the_easy-rsa_Scripts){: width="730px" padding:10px } un par de enlaces interesantes donde esta todo muy bien explicado. A continuación un registro de mi instalación:

# cp -a /usr/share/easy-rsa /root/easy-rsa-servidor
# cd /root/easy-rsa-servidor

export KEY_COUNTRY="ES"
export KEY_PROVINCE="Madrid"
export KEY_CITY="Madrid"
export KEY_ORG="Parchis"
export KEY_EMAIL="mi@correo.com"
export KEY_CN="servidor.dominio.com"
export KEY_NAME="LuisPa"
export KEY_OU="Parchis"

# cd /root/easy-rsa-servidor
# source ./vars
# ./clean-all
# ./build-ca
# ./build-key-server servidor.dominio.com
# ./build-dh

Creo la clave para cada los usuarios que se conectarán a este VPN Server, empiezo por la mía:

# ./build-key luis

Genero la Hash-based Message Authentication Code (HMAC):

# openvpn --genkey --secret /root/easy-rsa-servidor/keys/ta.key

Los ficheros quedan en el directorio **keys**:

- ca.crt: Certificado público de la Autoridad Certificadora (CA) que tendré que usar tanto en el servidor como en todos los clientes.
- servidor.dominio.com.crt y servidor.dominio.com.key: Certificado público y privado del servidor que solo necesito usar en el Linux, no en los clientes.
- luis.crt y luis.key: Certificados público y privado del cliente que se creó con ./build-key luis y que se debe usar en el dispositivo de dicho usuario.

 

## OpenVPN

Muevo el directorio creado con easy-rsa a /etc/openvpn

# mv /root/easy-rsa-servidor /etc/openvpn

Edito y preparo el fichero de configuración que llamaré luispaVPN: /etc/openvpn/luispaVPN.conf

# server binding port
port 12112

# openvpn protocol, could be tcp / udp / tcp6 / udp6
proto udp

# tun/tap device
dev tun0

# keys configuration, use generated keys
ca easy-rsa-servidor/keys/ca.crt
cert easy-rsa-servidor/keys/servidor.dominio.com.crt
key easy-rsa-servidor/keys/servidor.dominio.com.key
dh easy-rsa-servidor/keys/dh1024.pem

# optional tls-auth key to secure identifying
# tls-auth example/ta.key 0

# OpenVPN 'virtual' network infomation, network and mask
server 192.168.254.0 255.255.255.0

# persistent device and key settings
persist-key
persist-tun
ifconfig-pool-persist ipp.txt

# pushing route tables
push "route 192.168.1.0 255.255.255.0"
push "dhcp-option DNS 192.168.1.1"

# connection
keepalive 10 120
comp-lzo

user nobody
group nobody

# logging
status openvpn-status.log
log /etc/openvpn/openvpn.log
verb 4

- Arranco el servicio con systemd, compruebo que funciona y lo habilito para que arranque durante el boot. Dado que el nombre del fichero es luispaVPN.conf entonces utilizo "luispaVPN" como nombre del servicio.

# mkdir /var/run/openvpn

# systemctl start openvpn@luispaVPN
:
# ps -ef 
:
nobody   13080     1  0 17:13 ?        00:00:00 /usr/sbin/openvpn --daemon --writepid /var/run/openvpn/luispaVPN.pid --cd /etc/openvpn/ --config luispaVPN.conf
:
#
# systemctl enable openvpn@luispaVPN

 

# Clientes

## MacOSX

Para conectar desde un MacOSX necesitas instalar un cliente especial. Uno muy popular es ![Tunnelblick](/assets/img/original/){: width="730px" padding:10px }:

- Descarga e instala el **cliente OpenVPN para MacOSX**: ![Tunnelblick](/assets/img/original/){: width="730px" padding:10px }
- Ejecutar Tunnelblick

El propio programa te guiará para que puedas crearte un fichero de configuración. Recuerda que tienes que hacerle llegar los ficheros ca.crt, luis.crt y luis.key.
