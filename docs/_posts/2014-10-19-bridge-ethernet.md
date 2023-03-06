---
title: "Bridge Ethernet"
date: "2014-10-19"
categories: linux
tags: movistar router cone nat iptables television
excerpt_separator: <!--more-->
---

![logo linux router](/assets/img/posts/logo-bridge-eth.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Pruebas de concepto para extender la red de mi casa a un sitio remoto a través de internet y poder consumir los servicios de IPTV de Movistar. Voy a usar dos Raspberry Pi, una en casa sirviendo dos túneles (datos e IPTV) y otra en remoto conectándose a ellos a través de Internet. 

Más info en los apuntes: [Router Linux para Movistar]({% post_url 2014-10-05-router-linux %}) y [videos bajo demanda]({% post_url 2014-10-18-movistar-bajo-demanda %}) con Fullcone NAT en linux. Aunque a nivel de rendimiento debaja mucho que desear, con la [Pi 4]({% post_url 2023-03-02-raspberry-pi-os %}) seguro que funcionaría mejor.

<br clear="left"/>
<!--more-->

## Arquitectura

Este es el Hardware que he utilizado:

- **2 x Raspberry Pi**
  - Para esta prueba de concepto voy a llamar `norte` al equipo que tiene el contrato Movistar y `sur` al equipo remoto.
- **2 x Dongle USB Ethernet** para ser más granular y poder hacer más virguerías a nivel de routing, policy based routing, control de tráfico, etc.
- **1 x Switch** con soporte de VLAN's e IGMP Snooping para la LAN del equipo remoto.

Entre ambas Pi's creo dos túneles que irán por puertos `udp` diferentes:

- 1) **Access Server** para tráfico normal de Internet. Lo montaré con [OpenVPN](https://openvpn.net) y UDP. El que hace de *Servidor* es `norte` y el *Cliente* (llama a casa) es `sur`.

- 2) **Bridge Ethernet** para tráfico IPTV. De nuevo usando [OpenVPN](https://openvpn.net) y UDP. El que hace de *Servidor* es `norte` y el *Cliente* (llama a casa) es `sur`.

El título del apunte es **Bridge Ethernet** porque fue lo que más me costo configurar, hay poca documentación y conmutar multicast por internet no es obvio. De todas formas no solo describo esa función sino que veremos más casos de uso, voy a crear **tres VLANs** que van a permitir:

- VLAN 6
  - Conectar clientes de `sur` que quiero que salgan a Internet a través de la conexión de `norte`, así hago pruebas de **routing** y si es necesario de **policy based routing**
- VLAN 206
  - Conectar Deco en `sur` para que consuma el tráfico IPTV de `norte`, para hacer pruebas de **conmutación de tráfico multicast por túneles encriptados** y el uso de **filtros de nivel 2**
- VLAN 100
  - Conectar clientes de `sur` que quiero que salgan a Internet a través del operador de `sur`. Esta es quizá la opción más sencilla pero veremos cómo configurar **Source NAT (o masquerade)**.
  
{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-01.jpg"
    caption="Arquitectura de la prueba de concepto"
    width="600px"
    %}

<br />

### Instalación de OpenVPN

Esta sección hay que **repetirla en ambas Pi's, en `norte` y en `sur` !!!**, más adelante veremos sus configuraciones específicas.

Primero me convierto en `root`

```console
$ sudo su -i
#
```

Primero actualizo.

```console
# apt update && apt upgrade -y && apt full-upgrade -y
# apt autoremove -y --purge
```

Aprovecho para limitar el log a pocos días :-)

```console
# journalctl --vacuum-time=15d
# journalctl --vacuum-size=500M
```

Verifico que el timezone es correcto y la hora se está sincronizando bien. 

```console
# dpkg -l | grep -i tzdata
ii  tzdata      2021a-1+deb11u8       all        time zone and daylight-saving time data
# date
vie 03 mar 2023 11:05:46 CET
# timedatectl
               Local time: vie 2023-03-03 11:05:49 CET
           Universal time: vie 2023-03-03 10:05:49 UTC
                 RTC time: n/a
                Time zone: Europe/Madrid (CET, +0100)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```

Lo tengo bien, **Europe/Madrid**, si no fuese el caso tendría que corregirlo con `apt -y install --reinstall tzdata` y `dpkg-reconfigure tzdata`

Instalo OpenVPN, Bridge Utils y algunas herramientas importantes.

```console
# apt install -y openvpn unzip bridge-utils \
         dnsutils tcpdump ebtables tree bmon
```

Preparo el directorio de trabajo de **easy-rsa**

```console
# cp -a /usr/share/easy-rsa /etc/openvpn/easy-rsa
```

<br />

## Servidor `norte`

El servidor `norte` es el que está en mi casa y que conectaremos físicamente al router de Movistar por duplicado. El motivo es sencillo, el primer puerto (`eth0`) será el principal por donde irá todo el tráfico del equipo, mientras que el segundo (`eth1`) lo dedicaré exclusivamente solicitar y recibir el tráfico IPTV.

<br />

### Networking `norte`

Este es el esquema de conexiones, describo además a modo informativo cuales son los rangos que maneja un router de movistar por defecto:

{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-02.jpg"
    caption="Networking del servidor norte"
    width="600px"
    %}

La configuración IP es inicialmente muy sencilla. Solo configuro `eth0` con una dirección IP fija. Dejo `eth1` inicialmente sin servicio, la activaré desde el servicio OpenVPN Bridge Ethernet.


- [/etc/dhcpcd.conf](https://gist.github.com/LuisPalacios/0513c8b1c2119da372d2f1e4fcea57d9)

Activo la nueva configuración:

```console
# service networking restart
:
# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    inet 192.168.1.2/24 brd 192.168.1.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
```

<br />

#### Activo el Forwarding IPv4

Edito el fichero `/etc/sysctl.conf` y modifico la lisguiente línea para que se active el forwarding: 

```console
net.ipv4.ip_forward=1
```

AUnque no va a actuar como router en la LAN local sí que va a conmutar tráfico entre los túneles y eth0 `+` eth1. Describo más adelante lo que falta de networking, nat, firewall, una vez que tengamos los túneles OpenVPN operativos.

<br />

### OpenVPN en `norte`

Veamos cómo configurar este equipo como un Servidor de acceso y bridge ethernet utilizando OpenVPN.

<br />

#### Certificados

Ya habíamos preparado al principio el paquete **easy-rsa** en `/etc/openvpn/easy-rsa`. Lo primero que hay que hacer, y solo hay que hacerlo una vez, es configurar los certificados, que usaré como servidor `norte` y otros que enviaré al cliente `sur`. 

- Empiezo creando el fichero `vars` 

```console
# cd /etc/openvpn/easy-rsa
# cat vars
set_var EASYRSA_DN           "org"
set_var EASYRSA_REQ_COUNTRY  "ES"
set_var EASYRSA_REQ_PROVINCE "MAD"
set_var EASYRSA_REQ_CITY     "Norte"
set_var EASYRSA_REQ_ORG      "Parchis"
set_var EASYRSA_REQ_EMAIL    "microrreo@gmail.com"
set_var EASYRSA_REQ_OU       "Parchis"
set_var EASYRSA_CA_EXPIRE    10950
set_var EASYRSA_CERT_EXPIRE  10950
```

- Crear la infraestructura PKI

```console
# ./easyrsa init-pki
Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/vars
init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /etc/openvpn/easy-rsa/pki
```

- Generar el certificado de la Certificate Authority (CA). Especificar el Common Name.

```console
# cd /etc/openvpn/easy-rsa
# ./easyrsa build-ca
:
Enter New CA Key Passphrase:
:
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:norte
:
Your new CA certificate file for publishing is at:
/etc/openvpn/easy-rsa/pki/ca.crt
```

- Generar ambos, el server certificate request y la key

```console
# cd /etc/openvpn/easy-rsa
# ./easyrsa gen-req norte nopass
:
Keypair and certificate request completed. Your files are:
req: /root/easy-rsa/pki/reqs/norte.req
key: /root/easy-rsa/pki/private/norte.key
```

- Firmar el el fichero con el certificado .crt que necesita el servidor

```console
# cd /etc/openvpn/easy-rsa
# ./easyrsa sign-req server norte
:
Certificate created at: /root/easy-rsa/pki/issued/norte.crt
```

- Generar los parámetros Diffie-Hellman (DH) que necesita el servidor

```console
# cd /etc/openvpn/easy-rsa
# ./easyrsa gen-dh
:
```

- Generarmos el secreto Hash-based Message Authentication Code (HMAC)

```console
# cd /etc/openvpn/easy-rsa
# openvpn --genkey secret /etc/openvpn/easy-rsa/pki/ta.key
```

<br />

#### Preparo los certificados para su uso

- Durante el proceso anterior se han creado ya los certificados que usará `norte` en su función de Access Server y de Bridge Ethernet, pero tenemos que colocarlos en su sitio. Copio los certificados y aprovecho para darles un nombre más significativo.

```console
# cd /etc/openvpn/server/keys
# cp /etc/openvpn/easy-rsa/pki/ca.crt norte.ca.crt
# cp /etc/openvpn/easy-rsa/pki/issued/norte.crt .
# cp /etc/openvpn/easy-rsa/pki/private/norte.key .
# cp /etc/openvpn/easy-rsa/pki/dh.pem norte.dh.pem
# cp /etc/openvpn/easy-rsa/pki/ta.key norte.ta.key
```

* Creo los certificados para el cliente **`sur`**: Desde este servidor crearemos certificados para que distintos clientes puedan conectar con él. En este ejemplo vamos a crear el certificado del cliente `sur` y empaquetarlo para enviarselo.


```console
# cd /etc/openvpn/easy-rsa
# ./easyrsa build-client-full sur_cliente_de_norte nopass
:
./pki/private/sur_cliente_de_norte.key
./pki/reqs/sur_cliente_de_norte.req
./pki/issued/sur_cliente_de_norte.crt

# cd /etc/openvpn/easy-rsa/pki
# cp ca.crt /tmp/norte.ca.crt
# cp issued/sur_cliente_de_norte.crt /tmp
# cp private/sur_cliente_de_norte.key /tmp
# cp ta.key /tmp/norte.ta.key
# cd /tmp
# tar cvfz sur_cliente_de_norte_keys.tgz norte.ca.crt sur_cliente_de_norte.crt sur_cliente_de_norte.key norte.ta.key

luis@norte~ $ pwd
/home/luis
luis@norte~ $ cp /tmp/sur_cliente_de_norte_keys.tgz .
```

<br />

#### Access Server `norte`

Ahora vamos a configurar el *servicio Access Server*. Creo el fichero principal de configuración y un par de ficheros de apoyo para definir parámetros para mis clientes (en realidad solo voy a tener a uno `sur`).

- [/etc/openvpn/server/norte_access_server.conf](https://gist.github.com/LuisPalacios/0b1094cd2203cb8c4e11bfdcc1da0b65)
- [/etc/openvpn/server/ipp.txt](https://gist.github.com/LuisPalacios/1faab36ba5857411f41b7fec652c723e)
- [/etc/openvpn/server/ccd/cliente_sur](https://gist.github.com/LuisPalacios/d5af811441f1088f9d2d76d91de3c52c)

Arranque del servicio

```console
# systemctl start openvpn-server@norte_access_server
# systemctl enable openvpn-server@norte_access_server
# systemctl status openvpn-server@norte_access_server
● openvpn-server@norte_access_server.service - OpenVPN service for norte_access_server
     Loaded: loaded (/lib/systemd/system/openvpn-server@.service; enabled; vendor preset: enabled)
                                                                  =======
     Active: active (running) since Sat 2014-10-19 11:44:57 CET; 1min 14s ago
             ======
```

<br />

#### Bridge Ethernet Server `norte`

El segundo es el *servicio Bridge Ethernet*. Creo el fichero principal de configuración (`.conf`) y varios ficheros de apoyo bastante autoexplicativos.

- [/etc/openvpn/server/norte_bridge_ethernet_server.conf](https://gist.github.com/LuisPalacios/6e4341fb4378ad4bc9100106ffc0d2b1)
- [/etc/openvpn/server/norte_bridge_ethernet_server_CONFIG.sh](https://gist.github.com/LuisPalacios/be850d8a0393c0a107896ae5bc460c8d)
- [/etc/openvpn/server/norte_bridge_ethernet_server_FW_CLEAN.sh](https://gist.github.com/LuisPalacios/9eeb4d9c2d7341feb7250e94e32a41e0)
- [/etc/openvpn/server/norte_bridge_ethernet_server_UP.sh](https://gist.github.com/LuisPalacios/c57eec842bf72c27674206ebc7bb51d2)
- [/etc/openvpn/server/norte_bridge_ethernet_server_DOWN.sh](https://gist.github.com/LuisPalacios/779ace4cce3421f2fa303093111cdc9a)


Cambio los permisos a los ficheros `*.sh` y arranco el servicio

```console
# cd /etc/openvpn/server
# chmod 755 norte_bridge_ethernet_server*.sh

# systemctl start openvpn-server@norte_bridge_ethernet_server
# systemctl enable openvpn-server@norte_bridge_ethernet_server
# systemctl status openvpn-server@norte_bridge_ethernet_server
● openvpn-server@norte_bridge_ethernet_server.service - OpenVPN service for norte_bridge_ethernet_server
     Loaded: loaded (/lib/systemd/system/openvpn-server@.service; enabled; vendor preset: enabled)
                                                                  =======
     Active: active (running) since Sun 2014-10-19 13:20:08 CET; 17s ago
             ======

# ip a 
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    inet 192.168.1.2/24 brd 192.168.1.255 scope global noprefixroute eth0

3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1492 qdisc pfifo_fast state UP group default qlen 1000
    inet 192.168.1.3/24 metric 300 scope global eth1

6: tun1: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1400 qdisc pfifo_fast state UNKNOWN group default qlen 2000
    link/none
    inet 192.168.224.1/24 scope global tun1

7: tap206: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master br206 state UNKNOWN group default qlen 1000
    link/ether be:64:00:02:06:02 brd ff:ff:ff:ff:ff:ff
8: br206: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1492 qdisc noqueue state UP group default qlen 1000
    link/ether 02:64:00:02:06:02 brd ff:ff:ff:ff:ff:ff
    inet 192.168.206.1/24 brd 192.168.206.255 scope global br206
```

<br />

### Nombre y dirección IP de `norte` en internet

Para poder llegar a `norte` con un nombre DNS y dirección IP públicos necesitas resolver un nombre DNS público para averiguar cuál es la IP Pública del router de Movistar. Además necesitamos que dicho router haga Port Forwarding.

<br />

#### Nombre DNS e IP Pública

Para acceder a un router casero desde internet es necesario que tenga un nombre del tipo `mirouter.midominio.com`. Conseguirlo es muy fácil usando un DNS dinámico. Se puede hacer con un dominio propio (que hayas comprado) o puedes incluso hacerlo con múltiples servicios que te ofrecen por ahí (del tipo miservidorcasero.proveedordns.com)

En mi caso, como decía, tengo un dominio propio y utilizo Dynamic DNS para actualizar la IP pública cada vez que cambia. Hay varias formas de hacerlo y no voy a entrar en detalle, busca en internet opciones para conseguirlo. En este laboratorio y ejemplos verás que he documentado usando el nombre y puertos siguientes. No son los reales pero te dan una idea de cómo configurar los tuyos propios.

En el laboratorio es el servidor `sur` el que llama a `norte` para construir los dos túneles, así que solo necesitamos dar de alta a este último en nuestro proveedor DNS.

- Servicio Access Server --> `norte.dominio.com, 12345 (udp)`
- Servicio Bridge Ethernet Server --> `norte.dominio.com, 12346 (udp)`

<br />

#### Port Forwarding en Router Movistar

Además es muy importante activar **Port Forwarding** en el Router de Movistar donde está ubicado `norte`. Aquí tienes una captura de la configuración. Recuerda elegir protocolo UDP al dar de alta cada registro.

{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-04.png"
    caption="Port Forwarding hacia mi servidor `norte`"
    width="850px"
    %}

<br />

### IGMP Proxy

Para que los Decos remotos puedan acceder conectarse es necesario configurar IGMP Proxy. La instalación es muy sencilla: `apt -y igmpproxy` y aquí tienes el fichero de configuración.

- [/etc/igmpproxy.conf](https://gist.github.com/LuisPalacios/c05fda1f8fe657a9baefe20eabc07fc4)

### Fullcone NAT

Tal como describo en el apunte [Videos bajo demanda]({% post_url 2014-10-18-movistar-bajo-demanda %}), es necesario soportar Fullcone NAT en linux paraque funcionen. Estos son los pasos en una Raspberry Pi


```console
# apt install raspberrypi-kernel-headers
# cd ~/
# wget https://github.com/LuisPalacios/rtsp-linux/archive/refs/heads/master.zip
# unzip master.zip
# rm master.zip
# cd ~/rtsp-linux-master
# make
# make modules_install

# modprobe nf_nat_rtsp
# lsmod | grep -i rtsp
nf_nat_rtsp            16384  0
nf_conntrack_rtsp      16384  1 nf_nat_rtsp
nf_nat                 49152  3 nf_nat_rtsp,nft_chain_nat,xt_MASQUERADE
nf_conntrack          139264  4 nf_nat,nf_conntrack_rtsp,nf_nat_rtsp,xt_MASQUERADE
```

- Para que se carge siempre con el boot del sistema modifico el fichero /etc/modules

```console
nf_nat_rtsp
```

<br />

---

<br />

## Servidor `sur`

El servidor `sur` es el que está en remoto. También cuenta con dos tarjetas de red pero para usos distintos a los que vimos antes.

<br />

### Networking `sur`

Configuro ambas interfaces, la `eth0` (puerto embebido de las Raspberry Pi) conectada al router o cable del operador, por donde espero recibir una IP dinámica, mi router por defecto y la dirección del DNS Server.

La `eth1` (puerto usb dongle gigabitethernet) conectada a mi switch con soporte de VLAN's e IGMP Snooping. En mi laboratorio he utilizado un Switch tp-link TL-SG108E, pero cualquiera de consumo con soporte de VLAN's e IGMP Snooping nos vale. Al final del apunte tienes capturas con la configuración del Switch.

{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-03.jpg"
    caption="Networking del servidor sur"
    width="600px"
    %}

Como decía, el primer puerto (`eth0`) lo usamos para conectarnos a nuestro proveedor de internet usando DHCP y el segundo (`eth1`) para dar servcio a la LAN privada, usando VLAN's: 

- VLAN 6
  - Conectar clientes de `sur` que quiero que salgan a Internet a través de la conexión de `norte`.
- VLAN 206
  - Conectar Deco en `sur` para que consuma el tráfico IPTV de `norte`
- VLAN 100
  - Conectar clientes de `sur` que quiero que salgan a Internet a través del operador de `sur`. 

- `/etc/dhcpcd.conf`

```console
## Parámetros estándar
hostname
clientid
persistent
option rapid_commit
option domain_name_servers, domain_name, domain_search, host_name
option classless_static_routes
option interface_mtu
require dhcp_server_identifier
slaac private

## Interfaz eth0, recibe IP, router y DNS por DHCP 
interface eth0

## Interfaz eth1 va al TRUNK y no quiero IP
interface eth1
nodhcp
noipv4

# Tres interfaces para las vlans 
# ver /etc/networki/interfaces.d/vlans
interface eth1.206
  nodhcp
  noipv4
interface eth1.6
  static ip_address=192.168.107.1/24
interface eth1.100
  static ip_address=192.168.10.1/24 
```

- `/etc/network/interfaces.d/vlans`

```console
auto eth1.2
iface eth1.2 inet manual
  vlan-raw-device eth1

auto eth1.6
iface eth1.6 inet manual
  vlan-raw-device eth1

auto eth1.100
iface eth1.100 inet manual
  vlan-raw-device eth1
```

Activo la nueva configuración:

```console
# service networking restart
:
# ip a
:
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    inet 192.168.1.82/24 brd 192.168.1.255 scope global dynamic noprefixroute eth0
       valid_lft 3279sec preferred_lft 2829sec
:
4: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 28:87:ba:12:26:43 brd ff:ff:ff:ff:ff:ff
5: eth1.206@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 28:87:ba:12:26:43 brd ff:ff:ff:ff:ff:ff
    inet 192.168.206.1/24 brd 192.168.207.255 scope global noprefixroute eth1.2
       valid_lft forever preferred_lft forever
6: eth1.6@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 28:87:ba:12:26:43 brd ff:ff:ff:ff:ff:ff
    inet 192.168.107.1/24 brd 192.168.107.255 scope global noprefixroute eth1.6
       valid_lft forever preferred_lft forever
7: eth1.100@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 28:87:ba:12:26:43 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.1/24 brd 192.168.10.255 scope global noprefixroute eth1.100
       valid_lft forever preferred_lft forever
```

<br />

#### Activo el Forwarding en IPv4

Edito el fichero `/etc/sysctl.conf` y modifico la lisguiente línea para que se active el forwarding. Para activarlo basta con ejecutar `sysctl -p`

```console
net.ipv4.ip_forward=1
```


**PENDIENTE: Configuración como router: 
 Routing
 NAT
 Forwarding
 Firewall**

<br />

### OpenVPN en `sur`

En esta sección describo cómo configuro openvpn en modo cliente para que se conecte con `norte`

<br />

#### Instalo los certificados de `sur`


Lo primero es instalarme los certificados como cliente de `norte`. Ya los había preparado y enviado a este equipo. Preparo un subdirectorio donde irán las claves, bajo `/etc/openvpn/client` y descomprimo los archivos.

```console
# mkdir -p /etc/openvpn/cliente/keys/sur_cliente_de_norte
# cd /etc/openvpn/client/keys/sur_cliente_de_norte/
# tar xvfz /home/luis/sur_cliente_de_norte_keys.tgz
:
# tree /etc/openvpn/client/
/etc/openvpn/client/
└── keys
    └── sur_cliente_de_norte
        ├── norte.ca.crt
        ├── norte.ta.key
        ├── sur_cliente_de_norte.crt
        └── sur_cliente_de_norte.key
```

<br />

#### Cliente del Access Server `norte`

Ahora configuro el *servicio cliente de un Access Server*, creo el fichero principal de configuración.

- `/etc/openvpn/server/sur_cliente_de_norte.conf`

```console
#
# Configuración CLIENTE de un tunel "Access Server" OpenVPN
#
# Soy "cliente", expondré el device tun1
client
dev tun1
proto udp

# Datos del "Access Server" OpenVpn con el que conecto
# Debe ser accesible vía internet y uso el mismo puerto 
# que configuré en el servidor norte.
remote norte.dominio.com 12345
comp-lzo
resolv-retry 30
nobind
persist-key
persist-tun

# Mis claves como cliente de norte
ca keys/sur_cliente_de_norte/norte.ca.crt
cert keys/sur_cliente_de_norte/sur_cliente_de_norte.crt
key keys/sur_cliente_de_norte/sur_cliente_de_norte.key
# Nivel extra de seguridad, firmo con HMAC el handshake SSL/TLS
tls-auth keys/sur_cliente_de_norte/norte.ta.key 1

# Mis rutas en mi LAN que expongo al Servidor
push "route 192.168.107.0 255.255.255.0"

# Ficheros de log y estado
status /etc/openvpn/client/sur_cliente_de_norte.status.log
log /etc/openvpn/client/sur_cliente_de_norte.log
verb 4
```

| Nota: remote norte.dominio.com |

```console
# tree /etc/openvpn/client
etc/openvpn/client/
├── sur_cliente_de_norte.conf
└── keys
    └── sur_cliente_de_norte
        ├── norte.ca.crt
        ├── norte.ta.key
        ├── sur_cliente_de_norte.crt
        └── sur_cliente_de_norte.key
```

- Arranque del servicio

```console
# systemctl start openvpn-server@sur_cliente_de_norte
# systemctl enable openvpn-server@sur_cliente_de_norte
# systemctl status openvpn-server@sur_cliente_de_norte
● openvpn-server@sur_cliente_de_norte.service - OpenVPN service for sur_cliente_de_norte
     Loaded: loaded (/lib/systemd/system/openvpn-server@.service; enabled; vendor preset: enabled)
                                                                  =======
     Active: active (running) since Sat 2014-10-19 12:20:07 CET; 1min 14s ago
             ======

# ip a show dev tun1
7: tun1: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 500
    link/none
    inet 192.168.224.2/24 scope global tun1
       valid_lft forever preferred_lft forever
```

<br />

#### Cliente Bridge Ethernet

Ahora configuro el *servicio cliente de un Bridge Ethernet Server*, creo el fichero principal de configuración.

- `/etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte.conf`

```console
# Cliente de un "Bridge Ethernet" OpenVPN
#
# Soy un cliente del servidor:
remote norte.midominio.com 12346
client

# Creo un device de tipo `tap` y uso udp como prortocolo.
proto udp
dev tap206

# Resto de parámetros del servidor
resolv-retry 30
nobind
persist-key
persist-tun

# Mis claves
ca keys/sur_cliente_de_norte/norte.ca.crt
cert keys/sur_cliente_de_norte/sur_cliente_de_norte.crt
key keys/sur_cliente_de_norte/sur_cliente_de_norte.key
# Nivel extra de seguridad, firmo con HMAC el handshake SSL/TLS
tls-auth keys/sur_cliente_de_norte/norte.ta.key 1

# Scripts para activar o desactivar el tunel
script-security 2
up /etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_UP.sh
down /etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_DOWN.sh

# Ficheros de log y estado
status /etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte.status.log
log /etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte.log
verb 4
```

- `/etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_CONFIG.sh`

```console
#!/bin/bash
# Fichero xxxxx_cliente_bridge_ethernet_de_yyyyy_CONFIG.sh
# Este fichero contiene los nombres de las interfaces y parámetros de cada uno de
# ellas. Los utilizan los scripts de arranque y parada del servicio Bridge Ethernet

# Configuración General
export mtu="1492"

# Para el Bridge
export EB_TAP="tap206"     # Nombre del interfaz tap (ver .conf), representa al tunel openvpn y que añadiré al bridge.
export EB_BRIDGE="br206"   # Interfaz virtual Bridge que voy a crear.
export EB_VLAN="eth1.206"  # Interfaz VLAN local que añadiré al bridge

# Configuración para el tunel openvpn (interfaz tapXXX)
# Las direcciones MAC's pueden ser cualquiera, obviamente que no se usen en otro sitio.
export mac_tap="be:64:00:02:06:02"       # MAC privada para el interfaz tap local que asociaré al bridge
export mac_bridge="02:64:00:02:06:02"    # MAC privada para el bridge local
# Configuración para el bridge local (interfaz brXXX)
# El rango puede ser cualquiera, una vez más que no e use en otro sitio
export bridge_ip_rango="192.168.206.0/24" # Rango que voy a usar en el bridge
export bridge_ip_local="192.168.206.2/24" # IP de este servidor en su interfaz brXXX (bridge local)
export bridge_ip_remota="192.168.206.1"   # IP de del servidor remoto en su interfaz brXXX (su propio bridge)
```

- `/etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_UP.sh`

```console
#!/bin/bash
# Script que se ejecuta al hacer un `start` del servicio Bridge Ethernet

# Interfaces, rutas + IP y MACs asociaré a las interfaces tap y bridge
. /etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_CONFIG.sh

# Activo el tunel IPSec
ip link set ${EB_TAP} address ${mac_tap}
ip link set ${EB_TAP} up

# SETUP BRIDGE
brctl addbr ${EB_BRIDGE}
brctl stp ${EB_BRIDGE} off                         # HUB: no uso STP
brctl setageing ${EB_BRIDGE} 0                     # HUB: olvidar MAC addresses, be a HUB
brctl setfd ${EB_BRIDGE} 0                         # HUB: elimino el forward delay
#ip link set ${EB_BRIDGE} promisc on              # entregar el paquete en local
ip link set ${EB_BRIDGE} address ${mac_bridge}     # Cada nodo debe tener una distinta
ip link set ${EB_BRIDGE} arp on
ip link set ${EB_BRIDGE} mtu ${mtu}
ip link set ${EB_BRIDGE} up

# Activatar VLAN y cambiar MTU
ip link set ${EB_VLAN} up
ip link set ${EB_VLAN} mtu ${mtu}

# Añadir interfaces al bridge
brctl addif ${EB_BRIDGE} ${EB_TAP}  # Añado tunel ipsec al bridge
brctl addif ${EB_BRIDGE} ${EB_VLAN} # Añado vlan al bridge

# Asignar una IP al Bridge si queremos que vaya todo por el bridge
# IMPORTANTÍSIMO poner /24 o asignará una /32 (no funcionará)
ip addr add ${bridge_ip_local} brd + dev ${EB_BRIDGE}

# Me aseguro de configurar bien el rp_filter
echo -n 0 > /proc/sys/net/ipv4/conf/${EB_BRIDGE}/rp_filter
echo -n 1 > /proc/sys/net/ipv4/conf/${EB_VLAN}/rp_filter
echo -n 1 > /proc/sys/net/ipv4/conf/${EB_TAP}/rp_filter

# Me aseguro de que el forwarding está funcionando
echo -n 1 > /proc/sys/net/ipv4/ip_forward

# Permito el tráfico
for i in `echo ${EB_TAP} ${EB_VLAN} ${EB_BRIDGE}`; do
    iptables -I INPUT -i ${i} -j ACCEPT
    iptables -I FORWARD -i ${i} -j ACCEPT
    iptables -I OUTPUT -o ${i} -j ACCEPT
done

# Tabla de routing para los Decos
grep -i "^206 Decos" /etc/iproute2/rt_tables > /dev/null 2>&1
if [ "$?" = 1 ]; then
    sudo echo "206 Decos" >> /etc/iproute2/rt_tables
fi
ip route add ${bridge_ip_rango} dev ${EB_BRIDGE} table Decos
ip route add default via ${bridge_ip_remota} table Decos
ip rule add from ${bridge_ip_rango} table Decos
```

- `/etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_DOWN.sh`

```console
#!/bin/bash
# Script que se ejecuta al hacer un `stop` del servicio Bridge Ethernet

# Interfaces, rutas + IP y MACs asociaré a las interfaces tap y bridge
. /etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_CONFIG.sh

# Quitar las reglas iptables
for i in `echo ${EB_TAP} ${EB_VLAN} ${EB_BRIDGE}`; do
    iptables -D INPUT -i ${i} -j ACCEPT 2>/dev/null
    iptables -D FORWARD -i ${i} -j ACCEPT 2>/dev/null
    iptables -D OUTPUT -o ${i} -j ACCEPT 2>/dev/null
done

# Eliminar la IP del bridge 
ip addr del ${bridge_ip_local} brd + dev ${EB_BRIDGE} 2>/dev/null

# Remove interfaces from the bridge
brctl delif ${EB_BRIDGE} ${EB_VLAN} 2>/dev/null
brctl delif ${EB_BRIDGE} ${EB_TAP} 2>/dev/null

# Destroy interface tunel IPSec
ip link set ${EB_TAP} down 2>/dev/null

# Destroy interface vlan
ip link set ${EB_VLAN} down 2>/dev/null

# Destroy the BRIDGE
ip link set ${EB_BRIDGE} down 2>/dev/null
brctl delbr ${EB_BRIDGE} 2>/dev/null

# Destruir la table de routing para los clientes Decos
#
ip rule del from ${bridge_ip_rango} table Decos
ip route del default via ${bridge_ip_remota} table Decos
ip route del ${bridge_ip_rango} dev ${EB_BRIDGE} table Decos
```

Cambio los permisos a los scripts

```console
# cd /etc/openvpn/client
# chmod 755 sur_cliente_bridge_ethernet_de_norte*.sh
```

- Arranque del servicio

```console
# systemctl start openvpn-client@sur_cliente_bridge_ethernet_de_norte
# systemctl enable openvpn-server@sur_cliente_bridge_ethernet_de_norte
# systemctl status openvpn-server@sur_cliente_bridge_ethernet_de_norte
root@dubai:/etc/openvpn/client# systemctl status openvpn-client@dubai_cliente_bridge_ethernet_de_avila.service
● openvpn-client@sur_cliente_bridge_ethernet_de_norte.service - OpenVPN service for sur_cliente_bridge_ethernet_de_norte
     Loaded: loaded (/lib/systemd/system/openvpn-client@.service; enabled; vendor preset: enabled)
                                                                  =======
     Active: active (running) since Sun 2014-10-19 14:10:18 CET; 17s ago
             ======
```

Ya tenemos a `sur` y `norte` conectados con un Bridge Ethernet.

```console
# ip a show dev tap206
8: tap206: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master br206 state UNKNOWN group default qlen 1000
    link/ether be:64:00:02:06:02 brd ff:ff:ff:ff:ff:ff

# ip a show dev br206
9: br206: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1492 qdisc noqueue state UP group default qlen 1000
    link/ether 02:64:00:02:06:02 brd ff:ff:ff:ff:ff:ff
    inet 192.168.206.2/24 brd 192.168.206.255 scope global br206
       valid_lft forever preferred_lft forever

# ip a show dev eth1.206
4: eth1.206@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1492 qdisc noqueue master br206 state UP group default qlen 1000
   (No hace falta dirección IP)

# brctl show
bridge name	bridge id		STP enabled	interfaces
br206  8000.026400020602 no   eth1.206
                              tap206

# ping 192.168.206.1
PING 192.168.206.1 (192.168.206.1) 56(84) bytes of data.
64 bytes from 192.168.206.1: icmp_seq=1 ttl=64 time=12.8 ms
64 bytes from 192.168.206.1: icmp_seq=3 ttl=64 time=13.0 ms
:
```

<br />

### DHCP Server

Para que el Deco reciba la dirección IP y opciones correctamente tengo que instalarme un servidor DHCP en el equipo remoto. En mi caso utilizo [Pi-hole casero]({% post_url 2021-06-20-pihole-casero %}), pero vale cualquiera. Lo que es importante es que se le pasen bien las opciones al Deco.



- `/etc/dhnsmasq.d/03-pihole-decos.conf`

```console
# DECOS
# No consigo que funcione bien a traves del vendor-class
#dhcp-vendorclass=set:decos,IAL]
#dhcp-range=tag:!decos,192.168.104.33,192.168.104.199,1h
#dhcp-range=tag:decos,192.168.104.200,192.168.104.223,1h
# Hago la asociacion por mac
dhcp-host=8c:61:a3:5e:82:0c,ij-deco-salon,192.168.104.200,set:decos
dhcp-host=2C:95:23:02:CF:75,ij-deco-servicio,192.168.104.201,set:decos
dhcp-option=tag:decos,option:router,192.168.104.1
dhcp-option=tag:decos,6,172.26.23.3
dhcp-option=tag:decos,240,':::::239.0.2.10:22222:v6.0:239.0.2.30:22222'



# vlan 204
dhcp-range=set:vlan204,192.168.206.10,192.168.206.20,1h
dhcp-option=tag:vlan206,option:router,192.168.206.2
dhcp-option=tag:vlan206,6,172.26.23.3
dhcp-option=tag:vlan206,240,':::::239.0.2.10:22222:v6.0:239.0.2.30:22222'
dhcp-host=DC:A6:33:AC:12:FE,deco206-eth,192.168.206.21,set:vlan206

```

<br />


### Configuración del tp-link TL-SG108E

Dejo aquí unas capturas con un ejemplo de configuración de un Switch TP-Link TLSG108E, donde he dedicado puertos a las VLAN 206, 6 y 100 y el puerto 8 en modo trunk donde conecto el interfaz `eth1` de mi raspberry Pi. Los puertos 1 al 7 son puertos de acceso, mientras que el puerto 8 es un puerto Trunk. 

{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-05.png"
    caption="Activo IGMP Snooping en el Switch"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-06.png"
    caption="Defino en qué puertos se hace Tag o Untag de qué VLAN's"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-07.png"
    caption="Qué tagging se hace en cada puertos"
    width="600px"
    %}
