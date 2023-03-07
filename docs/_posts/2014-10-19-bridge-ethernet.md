---
title: "Bridge Ethernet"
date: "2014-10-19"
categories: linux
tags: movistar router cone nat iptables television
excerpt_separator: <!--more-->
---

![logo linux router](/assets/img/posts/logo-bridge-eth.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Pruebas de concepto para extender la red de mi casa a un sitio remoto a través de internet y poder consumir los servicios de IPTV de Movistar. Utilicé Raspberry Pi 2, una en casa sirviendo dos túneles (datos e IPTV) y otra en remoto conectándose a ellos a través de Internet.

Este apunte está relacionado con [Router Linux para Movistar]({% post_url 2014-10-05-router-linux %}) y [videos bajo demanda]({% post_url 2014-10-18-movistar-bajo-demanda %}) con Fullcone NAT en linux. 

<br clear="left"/>
<!--more-->

| Actualización 2023: A nivel de rendimiento recuerdo que estas pruebas debajan mucho que desear y tuve problemas de configuración. He vuelto a probar hace poco con un par de [Pi 4 con Raspberry Pi OS 64bits]({% post_url 2023-03-02-raspberry-pi-os %}) que funcionan infinitamente mejor y de paso estoy actulizando el apunte. |


## Arquitectura

Este es el Hardware que he utilizado:

- **2 x Raspberry Pi 4B**
  - Para esta prueba de concepto voy a llamar `norte` al equipo que tiene el contrato Movistar y `sur` al equipo remoto.
- **2 x TP-Link Adaptador UE300-USB 3.0 A Gigabit Ethernet** para tener un segundo puerto físico y ser más granular, para poder hacer más virguerías a nivel de routing, policy based routing, control de tráfico, etc.
- **1 x Switch** con soporte de VLAN's e IGMP Snooping para la LAN del equipo remoto.

Entre ambas Pi's creo dos túneles que irán por dos puertos `udp` diferentes:

- 1) **Access Server** para tráfico normal de Internet. Lo montaré con [OpenVPN](https://openvpn.net) y UDP. El que hace de *Servidor* es `norte` y el *Cliente* (llama a casa) es `sur`.

- 2) **Bridge Ethernet** para tráfico IPTV. De nuevo usando [OpenVPN](https://openvpn.net) y UDP. El que hace de *Servidor* es `norte` y el *Cliente* (llama a casa) es `sur`.

En el equipo `sur` voy a montar **tres VLANs** que van a permitir tres servicios. El título del apunte, **Bridge Ethernet**, es uno de ellos, porque fue lo que más me costo configurar, hay poca documentación y conmutar multicast por internet no es obvio:

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

### Instalación de software

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


<br />

## Servidor `norte`

El servidor `norte` es el que está en mi casa y que conectaremos físicamente al router de Movistar por duplicado. El motivo es sencillo, el primer puerto (`eth0`) será el principal por donde irá todo el tráfico del equipo, mientras que el segundo (`eth1`) lo dedicaré exclusivamente a solicitar y recibir el tráfico IPTV.

{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-02.jpg"
    caption="Networking del servidor norte"
    width="600px"
    %}

Arriba tienes el esquema de conexiones y en él recuerdo a modo informativo cuales son los rangos que maneja un router 
de movistar por defecto.

<br />

### Networking `norte`

La configuración IP es inicialmente muy sencilla. Si consultas el `dhcpcd.con` verás que solo configuro `eth0` con una dirección IP fija. La parte de `eth1` la dejo sin servicio, durante el boot NO se activará. La activo durante la ejecución de un script del apoyo del servicio *OpenVPN Bridge Ethernet Server*. El motivo es sencillo, la interfaz `eth1`(dongle usb) la uso exclusivamente para consumir el tráfico IPTV del router de Movistar y "enchufarla" al tunel, no la quiero usar para absoluatamente nada más, así que su activación y desactivación está vinculada al momento en que se levanta o para el túnel.


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

#### Forwarding IPv4

Edito el fichero `/etc/sysctl.conf` y modifico la lisguiente línea para que se active el forwarding. Para activarlo basta con ejecutar `sysctl -p`

```console
net.ipv4.ip_forward=1
```

<br />

#### NAT y Firewall

Este equipo no va a actuar como router en la LAN local, pero sí que va a conmutar tráfico entre los túneles. En esta sección describo cómo configurar NAT y Firewall. 

Servicios y Scripts
  
- [/etc/systemd/system/internet_wait.service](https://gist.github.com/LuisPalacios/421b9b4c1bdda72d28fd2e12a621d8c8)
- [/etc/systemd/system/firewall_1_pre_network.service](https://gist.github.com/LuisPalacios/caa9d72bcdc44ec1727452e9c6660074)
- [/etc/systemd/system/firewall_2_post_network.service](https://gist.github.com/LuisPalacios/1d5865d8bd59da1d2c077014a6485c3a)
- [/root/firewall/pi_eth1_up.sh](https://gist.github.com/LuisPalacios/8ff7a2d289d115a97969faa1788e7367)
- [/root/firewall/norte_firewall_clean.sh](https://gist.github.com/LuisPalacios/375aa2faa215e22a6a48f8cb3047e882)
- [/root/firewall/norte_firewall_inames.sh](https://gist.github.com/LuisPalacios/1a38011c97fc33f8c6e8a46497df5ef5)
- [/root/firewall/norte_firewall_1_pre_network.sh](https://gist.github.com/LuisPalacios/14c1a8474d9a39341b99bc30f804fc59)
- [/root/firewall/norte_firewall_2_post_network.sh](https://gist.github.com/LuisPalacios/b20f5ea512f1801ca72a13a7c7010f49)
- [/root/firewall/norte_verifica_conectividad.sh](https://gist.github.com/LuisPalacios/1c7e2e04676124de85ced92df57a1bd7)
- [/etc/systemd/system/watch_eth_bridge_con_sur.timer](https://gist.github.com/LuisPalacios/cd7dee3143e08971eba58cb19cbb9fe5)
- [/etc/systemd/system/watch_eth_bridge_con_sur.service](https://gist.github.com/LuisPalacios/f3d4c426d8208dc5fee3c6a847dcc087)
- [/etc/default/watch_eth_bridge_con_sur](https://gist.github.com/LuisPalacios/6d88dfc25ed09f704ffcae35a1512508)
- [/usr/bin/watch_eth_bridge.sh](https://gist.github.com/LuisPalacios/0e957f4522ad8da15a566d034fec336f)

Habilito los servicios y rearranco el equipo

```console
# chmod 755 /root/firewall/*.sh
# chmod 755 /usr/bin/watch_eth_bridge.sh
# systemctl enable internet_wait.service
# systemctl enable firewall_1_pre_network.service
# systemctl enable firewall_2_post_network.service
# reboot -f
```

<br />

### OpenVPN en `norte`

Veamos cómo configurar este equipo como un Servidor de acceso y bridge ethernet utilizando OpenVPN.

<br />

#### Certificados

 Lo primero que hay que hacer, y solo hay que hacerlo una vez, es configurar los certificados, que usaré como servidor `norte` y otros que enviaré al cliente `sur`. 
 
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

### IGMP Proxy en `norte`

Para que los Decos remotos puedan acceder conectarse es necesario configurar IGMP Proxy. La instalación es muy sencilla: `apt -y igmpproxy` y aquí tienes el fichero de configuración.

- [/etc/igmpproxy.conf](https://gist.github.com/LuisPalacios/c05fda1f8fe657a9baefe20eabc07fc4)

<br />

### Fullcone NAT en `norte`

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

### Networking `sur`

Configuro ambas interfaces, la `eth0` (puerto embebido de las Raspberry Pi) conectada al router o cable del operador, por donde espero recibir una IP dinámica, mi router por defecto y la dirección del DNS Server.

La `eth1` (puerto usb dongle gigabitethernet) conectada a mi switch con soporte de VLAN's e IGMP Snooping. En mi laboratorio he utilizado un Switch tp-link TL-SG108E, pero cualquiera de consumo con soporte de VLAN's e IGMP Snooping nos vale. Al final del apunte tienes capturas con la configuración del Switch.

Como decía, el primer puerto (`eth0`) lo usamos para conectarnos a nuestro proveedor de internet usando DHCP y el segundo (`eth1`) para dar servcio a la LAN privada, usando VLAN's: 

VLAN | Descripción
-------|-------------------
`6` | Clientes de `sur` que quiero que salgan a Internet a través de la conexión de `norte`
`100` | Clientes de `sur` que quiero que salgan a Internet a través del operador de `sur`
`206` | Deco en `sur` para que consuma el tráfico IPTV de `norte`

Preparo los ficheros de networking y activo la nueva configuración:

- [/etc/dhcpcd.conf](https://gist.github.com/LuisPalacios/7f36aa70890dbf9a9cb72fda3250ef7a)
- [/etc/network/interfaces.d/vlans](https://gist.github.com/LuisPalacios/695a0a0a592e4a6526bb0f87cccc9ede)

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

#### Forwarding en IPv4

Edito el fichero `/etc/sysctl.conf` y modifico la lisguiente línea para que se active el forwarding. Para activarlo basta con ejecutar `sysctl -p`

```console
net.ipv4.ip_forward=1
```

<br /> 

#### NAT y Firewall

Este equipo actúa como router entre las diferentes interfaces y redes disponibles, así que es importante definir y configurar sus opciones de NAT y Firewall.

Servicios y Scripts
  
- [/etc/systemd/system/internet_wait.service](https://gist.github.com/LuisPalacios/421b9b4c1bdda72d28fd2e12a621d8c8)
- [/etc/systemd/system/firewall_1_pre_network.service](https://gist.github.com/LuisPalacios/ad2a727e744f323f911f1a602da5b70e)
- [/etc/systemd/system/firewall_2_post_network.service](https://gist.github.com/LuisPalacios/9d7131feb3503d327341065e93e01f18)
- [/root/firewall/pi_eth1_up.sh](https://gist.github.com/LuisPalacios/8ff7a2d289d115a97969faa1788e7367)
- [/root/firewall/sur_firewall_clean.sh](https://gist.github.com/LuisPalacios/df48ebd0d19c4bd2aef6d72e1111b49b)
- [/root/firewall/sur_firewall_inames.sh](https://gist.github.com/LuisPalacios/cfffe7546faf1abed9d5bc48575e5dcc)
- [/root/firewall/sur_firewall_1_pre_network.sh](https://gist.github.com/LuisPalacios/16265be825109a5fd45d303aac8106b7)
- [/root/firewall/sur_firewall_2_post_network.sh](https://gist.github.com/LuisPalacios/c218c0a3ac0fdc791f9576475620789a)
- [/root/firewall/sur_verifica_conectividad.sh](https://gist.github.com/LuisPalacios/eee992475e67e3425a73720d43df1f4d)
- [/etc/systemd/system/watch_eth_bridge_con_norte.timer](https://gist.github.com/LuisPalacios/b6809e3c838a800f5f250b53e616bdc9)
- [/etc/systemd/system/watch_eth_bridge_con_norte.service](https://gist.github.com/LuisPalacios/5dff1345f6203a55e27c1efea426eac4)
- [/etc/default/watch_eth_bridge_con_norte](https://gist.github.com/LuisPalacios/0d4b6f84bb7afaff78ed197ba39ad605)
- [/usr/bin/watch_eth_bridge.sh](https://gist.github.com/LuisPalacios/0e957f4522ad8da15a566d034fec336f)

Habilito los servicios y rearranco el equipo

```console
# chmod 755 /root/firewall/*.sh
# chmod 755 /usr/bin/watch_eth_bridge.sh
# systemctl enable internet_wait.service
# systemctl enable firewall_1_pre_network.service
# systemctl enable firewall_2_post_network.service
# reboot -f
```

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

#### Cliente del Access Server

Ahora configuro el *servicio cliente del Access Server en `norte`*. Creo el fichero principal de configuración y luego arranco el servicio.

- [/etc/openvpn/server/sur_cliente_de_norte.conf](https://gist.github.com/LuisPalacios/5de5f4b594fc18fae8578e9c1cf9e062)


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

luis@sur$ ping 192.168.224.1
PING 192.168.224.1 (192.168.224.1) 56(84) bytes of data.
64 bytes from 192.168.224.1: icmp_seq=1 ttl=64 time=17.8 ms
64 bytes from 192.168.224.1: icmp_seq=2 ttl=64 time=17.6 ms
64 bytes from 192.168.224.1: icmp_seq=3 ttl=64 time=16.7 ms
^C
```

<br />

#### Cliente del Bridge Ethernet

Ahora configuro el *servicio cliente del Bridge Ethernet de `norte`*. Creo el fichero principal de configuración, los scripts de apoyo y arranco el servicio.

- [/etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte.conf](https://gist.github.com/LuisPalacios/823ff8491f181188b0793310c540188f)
- [/etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_CONFIG.sh](https://gist.github.com/LuisPalacios/358f038b84f527f89e238c3c2eb70b95)
- [/etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_UP.sh](https://gist.github.com/LuisPalacios/baa778c216b5d1560dad332ab6cacce1)
- [/etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_DOWN.sh](https://gist.github.com/LuisPalacios/dc60bc84ede46594cc2a0f7dec884255)


```console
# cd /etc/openvpn/client
# chmod 755 sur_cliente_bridge_ethernet_de_norte*.sh

# systemctl start openvpn-client@sur_cliente_bridge_ethernet_de_norte
# systemctl enable openvpn-server@sur_cliente_bridge_ethernet_de_norte
# systemctl status openvpn-server@sur_cliente_bridge_ethernet_de_norte
root@dubai:/etc/openvpn/client# systemctl status openvpn-client@dubai_cliente_bridge_ethernet_de_avila.service
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

#### DNS/DHCP Server en `sur` (Pendiente)

Vamos a necesitar un DHCP Server en `sur` para poder servir IP's en las interfaces LAN para sus clientes. Además es importante que el Deco reciba su dirección IP y unas opciones muy concretas. 

En mi caso siempre me instalo el [Pi-hole casero]({% post_url 2021-06-20-pihole-casero %}), pero valdría cualquier servidor DHCP. 

- [/etc/dhnsmasq.d/03-pihole-decos.conf](https://gist.github.com/LuisPalacios/56218937108e19048ed89c2133dd8bfe)


Pendiente: Documentar DNS Server y resto de opciones DHCP para las dos LAN's locales.

<br />

### Switch en `sur`

Como dije al principio, en la red LAN de `sur` necesitamos un pequeño switch que soporte VLAN's e IGMP Snooping. En mi caso me he decantado por tp-link TL-SG108E.

Puerto | VLAN - Descripción
-------|-------------------
`1,2` | Puertos VLAN 206, para los Decos, que se conectarán a Movistar a través del túnel bridge-eternet con `norte`
`3,4` | Puertos VLAN 6, para clietnes que salen a Internet a través de la conexión vía `norte`
`5,6,7` | Puertos VLAN 100, para clietnes que salen a Internet a través de la conexión del proveedor local en `sur`
`8` | Puerto TRUNK vlan's 6,206,100 donde conecto mi Raspberry Pi a su `eth1`(dongle usb)

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


<br />

### Salud del servicio

Dejo aquí unos cuantos comandos para verificar el estado de salud de las conexiones: 

**Norte**

- [/root/firewall/norte_verifica_conectividad.sh](https://gist.github.com/LuisPalacios/1c7e2e04676124de85ced92df57a1bd7)

**Sur**

- [/root/firewall/sur_verifica_conectividad.sh](https://gist.github.com/LuisPalacios/eee992475e67e3425a73720d43df1f4d)

<br />
