---
title: "Bridge Ethernet"
date: "2014-10-19"
categories: linux
tags: movistar router cone nat iptables television
excerpt_separator: <!--more-->
---

![logo linux router](/assets/img/posts/logo-bridge-eth.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Pruebas de concepto para extender la red de mi casa a un sitio remoto a través de internet, desde donde consumir los servicios de IPTV de Movistar. Utilicé un par de Raspberry Pi 2, conectadas entre sí por un par de túneles IPSec.

Este apunte está relacionado con [Router Linux para Movistar]({% post_url 2014-10-05-router-linux %}) y [videos bajo demanda]({% post_url 2014-10-18-movistar-bajo-demanda %}) con Fullcone NAT en linux. 

<br clear="left"/>
<!--more-->

| Actualización 2023: A nivel de rendimiento recuerdo que estas pruebas debajan mucho que desear y tuve problemas de configuración. He vuelto a probar hace poco con un par de [Pi 4 con Raspberry Pi OS 64bits]({% post_url 2023-03-02-raspberry-pi-os %}) que funcionan infinitamente mejor y de paso he actualizado este apunte. |


## Arquitectura

Este es el Hardware que he utilizado:

- **2 x Raspberry Pi 4B v1.5**
  - Llamo `norte` al equipo que tiene el contrato Movistar y `sur` al equipo remoto.
- **2 x TP-Link Adaptador UE300-USB 3.0 A Gigabit Ethernet** para tener un segundo puerto físico y ser más granular, hacer más virguerías a nivel de routing, policy based routing, control de tráfico, etc.
- **1 x Switch** con soporte de VLAN's e IGMP Snooping para la LAN del equipo remoto.

En `norte` creo dos túneles IPSec/UDP en modo Servidor (con [OpenVPN](https://openvpn.net)):

- 1) **Access Server** para tráfico normal de Internet
- 2) **Bridge Ethernet** para tráfico IPTV

En `sur` me conecto como cliente y creo **tres VLANs** en la LAN:

VLAN | Función
-------|-------------------
`10` | Clientes de `sur` que salen a Internet por proveedor local en `sur`
`107` | Clientes de `sur` que salen a Internet a través de `norte`.
`206` | Deco en `sur` para que consuma el tráfico IPTV de `norte`.

{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-01.jpg"
    caption="Arquitectura de la prueba de concepto"
    width="600px"
    %}

<br />

### Instalación de software

Actualizo el Raspberry Pi OS e instalo software. Repito estos comandos en ambas Pi's.

Desde `root`

```console
$ sudo su -i
#
```

Actualizo el sistema operativo.

```console
# apt update && apt upgrade -y && apt full-upgrade -y
# apt autoremove -y --purge
```

Limito el log a pocos días, esto va por gustos.

```console
# journalctl --vacuum-time=15d
# journalctl --vacuum-size=500M
```

Verifico que el timezone es correcto y la hora se está sincronizando. 

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

<br />

---
---
---
---

<br />

## Servidor `norte`

El servidor `norte` es el que está en mi casa con conexión directa al router de Movistar con ambas interfaces. El primer puerto (`eth0`) será el principal por donde irá todo el tráfico normal, mientras que el segundo (`eth1`) lo dedicaré exclusivamente a tráfico IPTV.

{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-02.jpg"
    caption="Networking del servidor norte"
    width="600px"
    %}

Arriba tienes el esquema de conexiones. He incluido a modo informativo cuales son los rangos que maneja un router 
de movistar por defecto.

<br />

### Networking

La configuración IP de `norte` es sencilla. Si consultas el `dhcpcd.conf` de más abajo verás que solo configuro `eth0` con una dirección IP fija. La parte de `eth1` la dejo sin servicio. El motivo por el que no la configuro es que lo hago más tarde desde el script que levanta el tunel *Bridge Ethernet Server*.

- [/etc/dhcpcd.conf](https://gist.github.com/LuisPalacios/0513c8b1c2119da372d2f1e4fcea57d9)

Aunque no activo `eth1` durante el boot, para que funcione el TP-Link Adaptador UE300 necesito crear el fichero siguiente (no se hará efectivo hasta el próximo reboot). 

- [/etc/udev/rules.d/50-usb-realtek-net.rules](https://gist.github.com/LuisPalacios/7f78efbcb6d57ff29d72209e1a5c43a6)

Para evitar que **`networkd`** elimine reglas o rutas que se establecen por fuera de su control modifico el fichero `networkd.conf`. Un ejemplo es si usamos `RIP` (vía [frr](https://frrouting.org)) para recibir rutas, otro ejemplo es si usamos el comando `ip rule` para hacer policy based routing (de hecho en este apunte lo utilizo). 

- `/etc/systemd/networkd.conf`

```console
[Network]
#SpeedMeter=no
#SpeedMeterIntervalSec=10sec
ManageForeignRoutingPolicyRules=no          # Cambiarlo a "no" !!!
ManageForeignRoutes=no                      # Cambiarlo a "no" !!!
#RouteTable=

[DHCPv4]
#DUIDType=vendor
#DUIDRawData=

[DHCPv6]
#DUIDType=vendor
#DUIDRawData=
```

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

#### Forwarding IPv4

Edito el fichero `/etc/sysctl.conf` y modifico la lisguiente línea para que se active el forwarding. Para activarlo sin rearrancar ejecuta `sysctl -p`

```console
net.ipv4.ip_forward=1
```

<br />

#### NAT y Firewall

Este equipo no va a actuar como router en la LAN local, pero sí que va a conmutar tráfico entre los túneles. 

Estos son los Servicios y Scripts que he creado:
  
- [/etc/systemd/system/internet_wait.service](https://gist.github.com/LuisPalacios/421b9b4c1bdda72d28fd2e12a621d8c8)
- [/etc/systemd/system/firewall_1_pre_network.service](https://gist.github.com/LuisPalacios/caa9d72bcdc44ec1727452e9c6660074)
- [/etc/systemd/system/firewall_2_post_network.service](https://gist.github.com/LuisPalacios/1d5865d8bd59da1d2c077014a6485c3a)
- [/root/firewall/norte_firewall_clean.sh](https://gist.github.com/LuisPalacios/375aa2faa215e22a6a48f8cb3047e882)
- [/root/firewall/norte_firewall_inames.sh](https://gist.github.com/LuisPalacios/1a38011c97fc33f8c6e8a46497df5ef5)
- [/root/firewall/norte_firewall_1_pre_network.sh](https://gist.github.com/LuisPalacios/14c1a8474d9a39341b99bc30f804fc59)
- [/root/firewall/norte_firewall_2_post_network.sh](https://gist.github.com/LuisPalacios/b20f5ea512f1801ca72a13a7c7010f49)
- [/root/firewall/norte_verifica_conectividad.sh](https://gist.github.com/LuisPalacios/1c7e2e04676124de85ced92df57a1bd7)

Además preparo un servicio que **vigila el túnel bridge ethernet**

- [/etc/systemd/system/watch_eth_bridge_con_sur.timer](https://gist.github.com/LuisPalacios/cd7dee3143e08971eba58cb19cbb9fe5)
- [/etc/systemd/system/watch_eth_bridge_con_sur.service](https://gist.github.com/LuisPalacios/f3d4c426d8208dc5fee3c6a847dcc087)
- [/etc/default/watch_eth_bridge_con_sur](https://gist.github.com/LuisPalacios/f4366fb5609d1c08759cf0c256fdb49a)
- [/usr/bin/watch_eth_bridge.sh](https://gist.github.com/LuisPalacios/0d059a520bc10bb4ee39342d28f52c16)

Habilito los servicios (se activará todo en el próximo reboot)

```console
# chmod 755 /root/firewall/*.sh
# chmod 755 /usr/bin/watch_eth_bridge.sh
# systemctl enable internet_wait.service
# systemctl enable firewall_1_pre_network.service
# systemctl enable firewall_2_post_network.service
```

De momento no rearranco el equipo, sigo configurando.

<br />

### OpenVPN en `norte`

#### Certificados

Lo primero que hay que hacer, y solo hay que hacerlo una vez, es configurar los certificados del equipo que hace de “servidor” (`norte`). 
 
 - Preparo el directorio de trabajo de **easy-rsa**

```console
# cp -a /usr/share/easy-rsa /etc/openvpn/easy-rsa
```

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

- Firmar el el fichero con el certificado `.crt` que necesita el servidor

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

- Durante el proceso anterior se han creado ya los certificados que usará `norte` en su función de Access Server y de Bridge Ethernet Server, pero tenemos que colocarlos en su sitio. Copio los certificados y aprovecho para darles un nombre más significativo.

```console
# cd /etc/openvpn/server/keys
# cp /etc/openvpn/easy-rsa/pki/ca.crt norte.ca.crt
# cp /etc/openvpn/easy-rsa/pki/issued/norte.crt .
# cp /etc/openvpn/easy-rsa/pki/private/norte.key .
# cp /etc/openvpn/easy-rsa/pki/dh.pem norte.dh.pem
# cp /etc/openvpn/easy-rsa/pki/ta.key norte.ta.key
```

* Creo los certificados para el cliente **`sur`** y lo empaqueto para enviarselo.


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

#### `norte` como Access Server

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

#### `norte`como Bridge Ethernet Server

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

### `norte` en Internet

Para poder llegar a `norte` con un nombre DNS y dirección IP públicos necesitas resolver su **nombre DNS público** para averiguar cuál es la IP Pública del router de Movistar. Además necesitamos que dicho router haga Port Forwarding.

<br />

#### Nombre DNS e IP Pública

Para acceder a un router casero desde internet es necesario que tenga un nombre del tipo `mirouter.midominio.com`. Conseguirlo es muy fácil usando DNS dinámico. Se puede hacer con un dominio propio (que hayas comprado) o puedes incluso hacerlo con múltiples servicios que te ofrecen por ahí (del tipo miservidorcasero.proveedordns.com)

En mi caso, como decía, tengo un dominio propio y utilizo Dynamic DNS para actualizar la IP pública cada vez que cambia. Hay varias formas de hacerlo y no voy a entrar en detalle, busca en internet opciones para conseguirlo. En este laboratorio y ejemplos verás que he documentado usando el nombre y puertos de más abajo. No son los reales pero te dan una idea de cómo configurar los tuyos propios.

En el laboratorio es el servidor `sur` el que llama a `norte` para construir los dos túneles, así que en este caso solo tengo que preocuparme de configurar `norte` en mi proveedor DNS.

- Servicio Access Server --> `norte.dominio.com, 12345 (udp)`
- Servicio Bridge Ethernet Server --> `norte.dominio.com, 12346 (udp)`

<br />

#### Port Forwarding en Router Movistar

Activo **Port Forwarding** en el Router de Movistar donde está ubicado `norte`. Aquí tienes una captura de la configuración. Recuerda elegir protocolo UDP al dar de alta cada registro.

{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-04.png"
    caption="Port Forwarding desde el router de movistar a mi servidor `norte`"
    width="850px"
    %}

<br />

### IGMP Proxy 

Por el interfaz del Bridge `br206` de `norte` van a llegar los `join` multicast del Deco remoto (`sur`). Llegan hasta ahí, por lo que necesito reenviarlos y hacer de intermediario. Esa es la función de `igmpproxy` en norte: escucha por el downstream (interfaz `br206`) y reenvía por su upstream (interfaz `eth1`).


Instalo el software

```console
# apt install -y igmpproxy
```

Preparo el fichero de configuración.

- [/etc/igmpproxy.conf](https://gist.github.com/LuisPalacios/c05fda1f8fe657a9baefe20eabc07fc4)

Habilito su arranque durante el boot

```console
# systemctl enable igmpproxy
```

<br />

### Fullcone NAT

Tal como describo en el apunte [Videos bajo demanda]({% post_url 2014-10-18-movistar-bajo-demanda %}), es necesario activar Fullcone NAT para que funcionen los flujos de tipos RTSP (grabaciones, series, películas, rebobinar, etc).

Compilo e instalo en el sistema operativo Raspberry Pi OS de `norte`:


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

- Para que se carge siempre con el boot del sistema modifico el fichero `/etc/modules`

```console
nf_nat_rtsp
```

- Configuro el sistema para que se llame a estos módulos al detectar flujos de tipo RTSP. Hay dos formas de hacerlo, dependiendo de qué versíon del kernel que tengas.

Automático: `sysctl -w net.netfilter.nf_conntrack_helper=1`, solo funciona hasta el Kernel 5.x.
Manual: `iptables -t raw -A PREROUTING -p tcp --dport 554 -j CT --helper rtsp`, funciona con cualquier versión de Kernel, incluida la 6.x.

| ¡Aviso! - Ahora es buen momento para hacer un reboot de `norte` |

```console
# reboot -f
```

<br />

---
---
---
---

<br />

## Servidor `sur`

El servidor `sur` es el que está en remoto. También cuenta con dos tarjetas de red pero para usos distintos a los que vimos antes.

{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-03.jpg"
    caption="Networking del servidor sur"
    width="600px"
    %}

<br />

### Networking

Configuro ambas interfaces, la `eth0` (puerto embebido de las Raspberry Pi) conectada al router del proveedor (IP dinámica, router por defecto y DNS Server).

La `eth1` (puerto usb dongle gigabitethernet) conectada a mi switch con soporte de VLAN's e IGMP Snooping. En mi laboratorio he utilizado un Switch tp-link TL-SG108E, pero cualquiera de consumo con soporte de VLAN's e IGMP Snooping nos vale. Al final del apunte tienes capturas con la configuración del Switch. En esta interfaz uso las VLAN's: 

VLAN | Función
-------|-------------------
`10` | Clientes de `sur` que salen a Internet por proveedor local en `sur`
`107` | Clientes de `sur` que salen a Internet a través de `norte`.
`206` | Deco en `sur` para que consuma el tráfico IPTV de `norte`.

Preparo los ficheros de networking y activo la nueva configuración:

- [/etc/dhcpcd.conf](https://gist.github.com/LuisPalacios/7f36aa70890dbf9a9cb72fda3250ef7a)
- [/etc/network/interfaces.d/vlans](https://gist.github.com/LuisPalacios/695a0a0a592e4a6526bb0f87cccc9ede)


Para que funcione bien el dongle TP-Link UE300 Gigabit Ethernet necesito crear este fichero. No se usará hasta el próximo reboot:

- [/etc/udev/rules.d/50-usb-realtek-net.rules](https://gist.github.com/LuisPalacios/7f78efbcb6d57ff29d72209e1a5c43a6)

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
5: eth1.206@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1492 qdisc noqueue master br206 state UP group default qlen 1000
    link/ether 28:87:ba:12:26:43 brd ff:ff:ff:ff:ff:ff
6: eth1.107@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 28:87:ba:12:26:43 brd ff:ff:ff:ff:ff:ff
    inet 192.168.107.1/24 brd 192.168.107.255 scope global noprefixroute eth1.107
7: eth1.10@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 28:87:ba:12:26:43 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.1/24 brd 192.168.10.255 scope global noprefixroute eth1.10
:
```

<br />

#### Forwarding en IPv4

Edito el fichero `/etc/sysctl.conf` y modifico la lisguiente línea para que se active el forwarding. Para activarlo basta con ejecutar `sysctl -p`

```console
net.ipv4.ip_forward=1
```

<br /> 

#### NAT y Firewall

Este equipo actúa como router entre las diferentes interfaces y redes disponibles, así que es importante definir y configurar sus opciones de NAT y Firewall.

Servicios y Scripts que necesitas crear:
  
- [/etc/systemd/system/internet_wait.service](https://gist.github.com/LuisPalacios/421b9b4c1bdda72d28fd2e12a621d8c8)
- [/etc/systemd/system/firewall_1_pre_network.service](https://gist.github.com/LuisPalacios/ad2a727e744f323f911f1a602da5b70e)
- [/etc/systemd/system/firewall_2_post_network.service](https://gist.github.com/LuisPalacios/9d7131feb3503d327341065e93e01f18)
- [/root/firewall/sur_firewall_clean.sh](https://gist.github.com/LuisPalacios/df48ebd0d19c4bd2aef6d72e1111b49b)
- [/root/firewall/sur_firewall_inames.sh](https://gist.github.com/LuisPalacios/cfffe7546faf1abed9d5bc48575e5dcc)
- [/root/firewall/sur_firewall_1_pre_network.sh](https://gist.github.com/LuisPalacios/16265be825109a5fd45d303aac8106b7)
- [/root/firewall/sur_firewall_2_post_network.sh](https://gist.github.com/LuisPalacios/c218c0a3ac0fdc791f9576475620789a)
- [/root/firewall/sur_verifica_conectividad.sh](https://gist.github.com/LuisPalacios/eee992475e67e3425a73720d43df1f4d)

Además preparo un servicio que **vigila el túnel bridge ethernet**

- [/etc/systemd/system/watch_eth_bridge_con_norte.timer](https://gist.github.com/LuisPalacios/b6809e3c838a800f5f250b53e616bdc9)
- [/etc/systemd/system/watch_eth_bridge_con_norte.service](https://gist.github.com/LuisPalacios/5dff1345f6203a55e27c1efea426eac4)
- [/etc/default/watch_eth_bridge_con_norte](https://gist.github.com/LuisPalacios/732bbfc06192a4d7c557f92277d50697)
- [/usr/bin/watch_eth_bridge.sh](https://gist.github.com/LuisPalacios/0d059a520bc10bb4ee39342d28f52c16)

Habilito los servicios (se activará todo en el próximo reboot)

```console
# chmod 755 /root/firewall/*.sh
# chmod 755 /usr/bin/watch_eth_bridge.sh
# systemctl enable internet_wait.service
# systemctl enable firewall_1_pre_network.service
# systemctl enable firewall_2_post_network.service
```

De momento no rearranco el equipo, sigo configurando y lo haré al final.

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

#### `sur` como cliente del Access Server

Ahora configuro el mi *servicio como cliente del Access Server de `norte`*. Creo el fichero principal de configuración y luego arranco el servicio.

- [/etc/openvpn/client/sur_cliente_access_de_norte.conf](https://gist.github.com/LuisPalacios/1ea5bccae15675b98d6cc133780b0fff)
- [/etc/openvpn/client/sur_cliente_access_de_norte_CONFIG.sh](https://gist.github.com/LuisPalacios/571629103be2f4db92aa2fd620a90006)
- [/etc/openvpn/client/sur_cliente_access_de_norte_DOWN.sh](https://gist.github.com/LuisPalacios/b54b27d34e9f3c718eb27fc3de977559)
- [/etc/openvpn/client/sur_cliente_access_de_norte_UP.sh](https://gist.github.com/LuisPalacios/59ed7e4df2e232689c555cf88bfdb733)


```console
# systemctl start openvpn-server@sur_cliente_access_de_norte
# systemctl enable openvpn-server@sur_cliente_access_de_norte
# systemctl status openvpn-server@sur_cliente_access_de_norte
● openvpn-server@sur_cliente_access_de_norte.service - OpenVPN service for sur_cliente_access_de_norte
     Loaded: loaded (/lib/systemd/system/openvpn-server@.service; enabled; vendor preset: enabled)
                                                                  =======
     Active: active (running) since Sat 2014-10-19 12:20:07 CET; 1min 14s ago
             ======

# ip a show dev tun1
7: tun1: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 500
    link/none
    inet 192.168.224.2/24 scope global tun1
       valid_lft forever preferred_lft forever

luis@sur$ ping 192.168.224.1
PING 192.168.224.1 (192.168.224.1) 56(84) bytes of data.
64 bytes from 192.168.224.1: icmp_seq=1 ttl=64 time=17.8 ms
64 bytes from 192.168.224.1: icmp_seq=2 ttl=64 time=17.6 ms
64 bytes from 192.168.224.1: icmp_seq=3 ttl=64 time=16.7 ms
^C
```

<br />

#### `sur` como cliente del Bridge Ethernet

Ahora configuro el *servicio cliente del Bridge Ethernet de `norte`*. Creo el fichero principal de configuración, los scripts de apoyo y arranco el servicio.

- [/etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte.conf](https://gist.github.com/LuisPalacios/823ff8491f181188b0793310c540188f)
- [/etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_CONFIG.sh](https://gist.github.com/LuisPalacios/358f038b84f527f89e238c3c2eb70b95)
- [/etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_UP.sh](https://gist.github.com/LuisPalacios/baa778c216b5d1560dad332ab6cacce1)
- [/etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_DOWN.sh](https://gist.github.com/LuisPalacios/dc60bc84ede46594cc2a0f7dec884255)
- [/etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_RT_UP.sh](https://gist.github.com/LuisPalacios/3d898a5c7a9ce48eff77896763c99ecd)
- [/etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_RT_DOWN.sh](https://gist.github.com/LuisPalacios/bfb30e26bbfe2ad2dbef433d83616c7c)


```console
# cd /etc/openvpn/client
# chmod 755 sur_cliente_bridge_ethernet_de_norte*.sh

# systemctl start openvpn-client@sur_cliente_bridge_ethernet_de_norte
# systemctl enable openvpn-server@sur_cliente_bridge_ethernet_de_norte
# systemctl status openvpn-server@sur_cliente_bridge_ethernet_de_norte
root@sur:/etc/openvpn/client# systemctl status openvpn-client@sur_cliente_bridge_ethernet_de_norte.service
● openvpn-client@sur_cliente_bridge_ethernet_de_norte.service - OpenVPN service for sur_cliente_bridge_ethernet_de_norte
     Loaded: loaded (/lib/systemd/system/openvpn-client@.service; enabled; vendor preset: enabled)
                                                                  =======
     Active: active (running) since Sun 2014-10-19 14:10:18 CET; 17s ago
             ======

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

#### DHCP Server 

![logo pihole](/assets/img/posts/logo-pihole.svg){: width="150px" height="150px" style="float:right; padding-right:25px" } 

En `sur` necesito instalar un servidor DHCP para servir IP's en sus interfaces LAN, en realidad en sus VLAN's, incluido el Deco y sus opciones concretas.

Para todo lo relacionado con DNS y DHCP llevo tiempo usando el proyecto [Pi-hole](https://pi-hole.net). Utiliza [`dnsmasq`](https://thekelleys.org.uk/dnsmasq/doc.html) para dar los servicios DNS y DHCP, aunque su verdadero secreto es que se trata de un sumidero de DNS (o DNS Sinkhole) que protege a los equipos de tu red de contenido no deseado, sin necesidad de instalar ningún software en los clientes.

En este laboratorio solo voy a usar la parte de DHCP (el sumidero y el DNS quizá en el futuro). Si quieres aprender más sobre el tema, te aconsejo leer el apunte [Pi-hole casero]({% post_url 2021-06-20-pihole-casero %}).

Ejecuto la instalación de Pi-hole (para más detalle consulta el enlace)

```console
$ curl -sSL https://install.pi-hole.net | bash
```

Estos son los ficheros de configuración para la parte de DHCP: 

- [/etc/dhnsmasq.d/01-pihole.conf](https://gist.github.com/LuisPalacios/dd2dd41690887957215cc5d88c0750d4)
- [/etc/dhnsmasq.d/02-pihole-dhcp.conf](https://gist.github.com/LuisPalacios/23adb47e03d7bbcfbf5602127c560d70)
- [/etc/dhnsmasq.d/03-pihole-decos.conf](https://gist.github.com/LuisPalacios/a681108193f24da6929588dbbedc0b2a)
- [/etc/dhnsmasq.d/04-pihole-sur.conf](https://gist.github.com/LuisPalacios/c109627b3ec2f4dbd390ec5ade9184bb)


| ¡Aviso! - Ahora es buen momento para hacer un reboot de `norte` |

```console
# reboot -f
```


<br />

### Switch en la LAN de `sur`

En la red LAN de `sur` necesitamos un switch que soporte VLAN's e IGMP Snooping. En mi caso me he decantado por tp-link TL-SG108E.

Puertos | VLAN - Descripción
-------|-------------------
`1,2` | VLAN 206. Deco que conecta a Movistar TV por túnel "bridge-eternet" vía `norte`
`3,4` | VLAN 107. Clientes que salen a Internet por túnel de "acceso" vía `norte`
`5,6,7` | VLAN 10. Clientes que salen a Internet por proveedor local en `sur`
`8` | TRUNK VLANs 206,107,10. Raspberry Pi a su `eth1`(dongle usb)


{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-05.png"
    caption="Dirección IP del propio Switch"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-06.png"
    caption="Activo IGMP Snooping en el Switch"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-07.png"
    caption="Defino en qué puertos se hace Tag o Untag de qué VLAN's"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-08.png"
    caption="Qué tagging se hace en cada puertos"
    width="600px"
    %}

Como curiosidd, una vez que tengamos todo funcionando podemos ver en el propio switch los grupos multicast activos: 

{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-09.png"
    caption="Grupos multicast activos"
    width="600px"
    %}


<br />

### Salud del servicio

Dejo aquí un script que verifica el estado de salud de las conexiones: 

**Norte**

- [/root/firewall/norte_verifica_conectividad.sh](https://gist.github.com/LuisPalacios/1c7e2e04676124de85ced92df57a1bd7)

```console
root@norte:~/firewall# ./norte_verifica_conectividad.sh
Unit (servicio) firewall_1_pre_network: IPTABLES (pre-net) ...                 [OK]
Unit (servicio) firewall_2_post_network: IPTABLES (post-net) ...               [OK]
Unit (servicio) watch_eth_bridge_con_sur.timer: Vigilante ...                  [OK]
Unit (servicio) sshd.service: SSHD ...                                         [OK]
Probando interface: lo                                                         [OK]
Probando interface: eth0                                                       [OK]
Probando interface: eth1                                                       [OK]
Probando interface: br206                                                      [OK]
Probando interface: tun1                                                       [OK]
Probando IP localhost: localhost (lo) ...                                      [OK] 0.089 ms
Probando IP 192.168.1.1: Router de acceso a Internet ...                       [OK] 0.514 ms
Probando IP 192.168.224.2: Tunel Internet con Sur ...                          [OK] 12.471 ms
Probando IP 192.168.206.2: Tunel IPTV con Sur ...                              [OK] 12.261 ms
Probando IP 10.64.0.1: MOVISTAR IPTV ...                                       [OK] 3.273 ms
Comprobando Kernel: /proc/sys/net/ipv4/ip_forward  (OK=1)                      [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/lo/rp_filter  (OK=0)               [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/all/rp_filter  (OK=0)              [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/default/rp_filter  (OK=1)          [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/eth0/rp_filter  (OK=1)             [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/eth1/rp_filter  (OK=0)             [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/br206/rp_filter  (OK=0)            [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/tun1/rp_filter  (OK=1)             [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/tun1/forwarding  (OK=1)            [OK]
WAN Interfaz Internet ifWan              : eth0 - 192.168.1.2
LAN IPTV              ifLanIPTV          : eth1 - 192.168.1.3
Tunel Sur             ifTunelSur         : tun1
Bridge IPTV           ifBridgeIPTV       : br206 - 192.168.206.1
INTRANET : 192.168.1.0/24 192.168.206.0/24 192.168.107.0/24 192.168.10.0/24 192.168.224.0/24 192.168.222.0/24
```

**Sur**

- [/root/firewall/sur_verifica_conectividad.sh](https://gist.github.com/LuisPalacios/eee992475e67e3425a73720d43df1f4d)

```console
root@sur:~/firewall# ./sur_verifica_conectividad.sh

Unit (servicio) firewall_1_pre_network: IPTABLES (pre-net) ...                 [OK]
Unit (servicio) firewall_2_post_network: IPTABLES (post-net) ...               [OK]
Unit (servicio) watch_eth_bridge_con_norte.timer: Vigilante ...                [OK]
Unit (servicio) sshd.service: SSHD ...                                         [OK]
Probando interface: lo                                                         [OK]
Probando interface: eth0                                                       [OK]
Probando interface: br206                                                      [OK]
Probando interface: eth1.107                                                   [OK]
Probando interface: eth1.10                                                    [OK]
Probando interface: tun1                                                       [OK]
Probando IP localhost: localhost (lo) ...                                      [OK] 0.115 ms
Probando IP 192.168.1.1: Router de acceso a Internet ...                       [OK] 0.269 ms
Probando IP 192.168.107.254: Switch local ...                                  [OK] 2.183 ms
Probando IP 192.168.224.1: Tunel Internet con Norte ...                        [OK] 13.317 ms
Probando IP 192.168.206.1: Tunel IPTV con Norte ...                            [OK] 13.365 ms
Probando IP 10.64.0.1: MOVISTAR IPTV ...                                       [OK] 15.383 ms
Comprobando Kernel: /proc/sys/net/ipv4/ip_forward  (OK=1)                      [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/all/rp_filter  (OK=0)              [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/default/rp_filter  (OK=1)          [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/br206/rp_filter  (OK=0)            [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/eth1.107/rp_filter  (OK=1)         [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/eth1.10/rp_filter  (OK=1)          [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/tun1/rp_filter  (OK=1)             [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/tun1/forwarding  (OK=1)            [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/lo/rp_filter  (OK=0)               [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/eth0/rp_filter  (OK=1)             [OK]
Comprobando Kernel: /proc/sys/net/ipv4/conf/lo/rp_filter  (OK=0)               [OK]
WAN Interfaz Internet         : eth0 - 192.168.1.82
Bridge IPTV                   : br206 - 192.168.206.2
LAN Acceso Internet Via Norte : eth1.107 - 192.168.107.1
LAN Acceso Internet Via Sur   : eth1.10 - 192.168.10.1
INTRANET : 192.168.206.0/24 192.168.107.0/24 192.168.10.0/24 192.168.224.0/24 192.168.222.0/24
```

<br />
