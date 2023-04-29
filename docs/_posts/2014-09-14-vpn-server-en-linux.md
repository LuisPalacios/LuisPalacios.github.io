---
title: "OpenVPN Server"
date: "2014-09-14"
categories: seguridad
tags: linux vpn openvpn firewall túneles seguridad
excerpt_separator: <!--more-->
---

![logo openvpn](/assets/img/posts/logo-openvpn.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 

En este apunte técnico voy a describir cómo montar un VPN Server casero basado en [OpenVPN](https://openvpn.net/) que sigue siendo la mejor solución hoy en día, a pesar de que es más complejo de implementar. El objetivo es poder tener acceso a los servicios internos de mi red casera desde internet.


<br clear="left"/>
<!--more-->

- OpenVPN es la mejor solución VPN a día de hoy. Es fiable, rápido y lo más importante, muy seguro, incluso contra organismos que dicen comprometieron otros protocolos. Como contrapartida, su configuración es más compleja y tiene el inconveniente de necesitar un software adicional en los clientes.
- IKEv2 también es un protocolo rápido y seguro si se usa la implementación open source. Para lo usuarios móviles tiene la ventaja (sobre openvpn) de reconectarse. Es la única solución para usuarios de Blackberry.
- SSTP ofrece las mismas ventajas que OpenVPN pero solo para entornos Windows así que a olvidarse, creado por Microsoft y propietario.
- PPTP es muy **inseguro**, incluso Microsoft que participó en su desarrollo, lo ha abandonado. Tiene la ventaja de que es muy fácil de implementar y tiene compatibildiad en varias plataformas pero deberías evitarlo, una alternativa rápida es el siguiente: L2PT/IPsec mismas ventajas pero más seguro.
- L2TP/IPsec es una buena solucíon VPN para darle un uso no crítico y un montaje rápido sin software adicional, pero ojo! se comenta en los mentideros que también ha sido comprometido.

<br/>

## Instalación del Software

Prepararmos el fichero `/etc/portage/package.use/vpn`

```config
net-misc/openvpn      lzo -pam plugins ssl systemd iproute2 examples
```

Lanzamos la instalación.

```console
# emerge -v app-crypt/easy-rsa
# emerge -v openvpn
```

<br/>
 
## Infraestructura PKI

Es la primera vez que instalo openvpn así que necesito crear mi propia infraestructura PKI desde el principio. PKI significa Public Key Infrastructure y es el conjunto de recursos necesarios para crear certificados digitales. Dejo [aquí](http://sobrebits.com/montar-un-servidor-casero-con-raspberry-pi-parte-7-instalacion-y-configuracion-de-openvpn/) y [aquí](https://wiki.gentoo.org/wiki/Create_a_Public_Key_Infrastructure_Using_the_easy-rsa_Scripts) un par de enlaces interesantes donde esta todo muy bien explicado. A continuación un registro de mi instalación:

```console
# cp -a /usr/share/easy-rsa /root/easy-rsa-servidor
# cd /root/easy-rsa-servidor
```
Fichero de configuración `/root/easy-rsa-servidor`

```config
export KEY_COUNTRY="ES"
export KEY_PROVINCE="Madrid"
export KEY_CITY="Madrid"
export KEY_ORG="Parchis"
export KEY_EMAIL="mi@correo.com"
export KEY_CN="servidor.dominio.com"
export KEY_NAME="LuisPa"
export KEY_OU="Parchis"
```

```console
# cd /root/easy-rsa-servidor
# source ./vars
# ./clean-all
# ./build-ca
# ./build-key-server servidor.dominio.com
# ./build-dh
```

Creo la clave para cada los usuarios que se conectarán a este VPN Server, empiezo por la mía:

```console
# ./build-key luis
```

Genero la Hash-based Message Authentication Code (HMAC):

```console
# openvpn --genkey --secret /root/easy-rsa-servidor/keys/ta.key
```

Los ficheros quedan en el directorio **keys**:

- `ca.crt`: Certificado público de la Autoridad Certificadora (CA) que tendré que usar tanto en el servidor como en todos los clientes.
- `servidor.dominio.com.crt` y `servidor.dominio.com.key`: Certificado público y privado del servidor que solo necesito usar en el Linux, no en los clientes.
- `luis.crt` y `luis.key`: Certificados público y privado del cliente que se creó con `./build-key luis` y que se debe usar en el dispositivo de dicho usuario.
 
<br/>

## OpenVPN

Muevo el directorio creado con easy-rsa a /etc/openvpn

```console
# mv /root/easy-rsa-servidor /etc/openvpn
```

Edito y preparo el fichero de configuración que llamaré luispaVPN: `/etc/openvpn/luispaVPN.conf`

```config
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
```

- Arranco el servicio con systemd, compruebo que funciona y lo habilito para que arranque durante el boot. Dado que el nombre del fichero es `luispaVPN.conf` entonces utilizo `luispaVPN` como nombre del servicio.

```console
# mkdir /var/run/openvpn

# systemctl start openvpn@luispaVPN
:
# ps -ef 
:
nobody   13080     1  0 17:13 ?        00:00:00 /usr/sbin/openvpn --daemon --writepid /var/run/openvpn/luispaVPN.pid --cd /etc/openvpn/ --config luispaVPN.conf
:
#
# systemctl enable openvpn@luispaVPN
```

<br/>
 
## Cliente MacOSX

Para conectar desde un MacOSX necesitas instalar un cliente. Uno muy popular es [Passepartout](https://passepartoutvpn.app/):

- Descarga e instala el cliente OpenVPN para MacOSX: Passepartout
- Ejecutar Passepartout

Recuerda que tienes que hacerle llegar los ficheros `ca.crt, luis.crt y luis.key`.
