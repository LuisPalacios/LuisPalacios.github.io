---
title: "Bridge Ethernet"
date: "2014-10-19"
categories: linux
tags: movistar router cone nat iptables television
excerpt_separator: <!--more-->
---


![logo linux router](/assets/img/posts/logo-bridge-eth.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Pruebas de concepto para extender la red de mi casa a un sitio remoto a través de internet y poder consumir los servicios de IPTV de Movistar. Voy a usar dos Raspberry Pi, una en casa sirviendo dos túneles (datos e IPTV) y otra en remoto conectándose a ellos a través de Internet. 

Más info en los apuntes: [Router Linux para Movistar]({% post_url 2014-10-05-router-linux %}) y [videos bajo demanda]({% post_url 2014-10-18-movistar-bajo-demanda %}) con Fullcone NAT en linux. Aunque a nivel de rendimiento debaja mucho que desear, con la [Pi 4]({% post_url 2021-10-19-raspberry-pi-os %}) seguro que funcionaría mejor.

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
- VLAN 2
  - Conectar Deco en `sur` para que consuma el tráfico IPTV de `norte`, para hacer pruebas de **conmutación de tráfico multicast por túneles encriptados** y el uso de **filtros de nivel 2**
- VLAN 100
  - Conectar clientes de `sur` que quiero que salgan a Internet a través del contrato de `sur`. Esta es quizá la opción más sencilla pero veremos cómo configurar **Source NAT (o masquerade)**.
  
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
# apt -y install openvpn unzip bridge-utils \
         igmpproxy dnsutils tcpdump ebtables \
         tree
```

Preparo el directorio de trabajo de **easy-rsa**

```console
# cp -a /usr/share/easy-rsa /etc/openvpn/easy-rsa
```

<br />

## Servidor `norte`

El servidor `norte` es el que está en mi casa y que conectaremos físicamente al router de Movistar por duplicado. El motivo es sencillo, el primer puerto (`eth0`) será el principal por donde irá todo el tráfico del equipo, mientras que el segundo (`eth1`) lo dedicaré exclusivamente solicitar y recibir el tráfico IPTV.

<br />

### Networking

Conexión con Internet e IPTV
 setup de las interfaces

Configuración como router: 
 Routing
 NAT
 Forwarding
 Firewall

<br />

### OpenVPN

En esta sección describo cómo configuro OpenVPN en modo servidor

<br />

#### Certificados

- Tras preparar **easy-rsa** en `/etc/openvpn/easy-rsa` voy a crear un paquete de certificados que utilizaré para el servidor `norte`y sus `clientes`. Empiezo creando el fichero `vars` 

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

#### Instalo certificados en el servidor `norte`

- Durante el proceso anterior se han creado ya los certificados que usará `norte` en su función de Access Server y de Bridge Ethernet, pero tenemos que colocarlos en su sitio. 

- Copio los certificados y aprovecho para darles un nombre más significativo

```console
# cd /etc/openvpn/server/keys
# cp /etc/openvpn/easy-rsa/pki/ca.crt norte.ca.crt
# cp /etc/openvpn/easy-rsa/pki/issued/norte.crt .
# cp /etc/openvpn/easy-rsa/pki/private/norte.key .
# cp /etc/openvpn/easy-rsa/pki/dh.pem norte.dh.pem
# cp /etc/openvpn/easy-rsa/pki/ta.key norte.ta.key
```

<br />

#### Creo los certificados para `sur`

- Desde este servidor crearemos certificados para que distintos clientes puedan conectar con él. En este ejemplo vamos a crear el certificado del cliente `sur`.

```console
# cd /etc/openvpn/easy-rsa
# ./easyrsa build-client-full sur_cliente_de_norte nopass
:
./pki/private/sur_cliente_de_norte.key
./pki/reqs/sur_cliente_de_norte.req
./pki/issued/sur_cliente_de_norte.crt
```

- Empaqueto los certificados recien creados para `sur`

```console
# cd /etc/openvpn/easy-rsa/pki
# cp ca.crt /tmp/norte.ca.crt
# cp issued/sur_cliente_de_norte.crt /tmp
# cp private/sur_cliente_de_norte.key /tmp
# cp ta.key /tmp/norte.ta.key
# cd /tmp
# tar cvfz sur_cliente_de_norte_keys.tgz norte.ca.crt sur_cliente_de_norte.crt sur_cliente_de_norte.key norte.ta.key
```

- Guardo el fichero comprimido con los certificados de `sur` para enviárselo en el futuro y que los instale. Lo veremos en la siguietne sección.

```console
luis@norte~ $ pwd
/home/luis
luis@norte~ $ cp /tmp/sur_cliente_de_norte_keys.tgz .
```

<br />

#### Access Server `norte`

Ahora vamos a configurar el *servicio Access Server*. Creo el fichero principal de configuración y los de sus clientes. 

- `/etc/openvpn/server/norte_access_server.conf`

```console
# Configuración de "Access Server" de OpenVPN
#
# Soy "servidor", expondré el device tun0 y uso udp como prortocolo.
proto udp
dev tun1

# Datos de trabajo de mi servidor
port 1444
# El siguiente rango tiene que estar libre
server 192.168.224.0 255.255.255.0
comp-lzo
persist-key
persist-tun
client-to-client
topology subnet
keepalive 10 120

# Opciones de los túneles
sndbuf 512000
rcvbuf 512000
push "sndbuf 512000"
push "rcvbuf 512000"
txqueuelen 2000
tun-mtu 1400
mssfix 1360

# Mis claves de servidor
ca keys/norte.ca.crt
cert keys/norte.crt
key keys/norte.key
dh keys/norte.dh.pem
# Nivel extra de seguridad, firmo con HMAC el handshake SSL/TLS
tls-auth keys/norte.ta.key 0

# Rutas y DNS server que voy a exponer a mis clientes.
# Si quiero exponar mi "LAN" (de `norte`) quito el comentario
#push "route 192.168.X.0 255.255.255.0"
# Si quiero forzar a que los clientes usen mi DNS Server
#push "dhcp-option DNS 192.168.X.1"

# Ficheros de configuración de los clientes
ifconfig-pool-persist /etc/openvpn/server/ipp.txt
client-config-dir /etc/openvpn/server/ccd

# Rutas que voy a instalarme para saber cómo llegar a las
# LAN's de mis clientes. Ellos tienen que hacer un push
# de su rango en su fichero de cliente.
route 192.168.107.0 255.255.255.0 192.168.224.107 # LAN de sur

# Ficheros de log y estado
status /etc/openvpn/server/norte_access_server.status.log
log /etc/openvpn/server/norte_access_server.log
verb 4
```

- `/etc/openvpn/server/ipp.txt`

```console
cliente_sur,192.168.224.107,
```

- `/etc/openvpn/server/ccd/cliente_sur`

```console
# Nueva ruta a la que tengo acceso via `sur`, su LAN.
iroute 192.168.107.0 255.255.255.0
```

- Arranque del servicio

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

## Servidor `sur`

El servidor `sur` es el que está en remoto. También cuenta con dos tarjetas de red pero para usos distintos a los que vimos antes. El primer puerto (`eth0`) lo usamos para conectarnos a nuestro proveedor de internet usando DHCP y el segundo puerto (`eth1`) lo usamos para dar servcio a la LAN privada. 

<br />

### Networking

Conexión con Internet y LAN
 setup de las VLAN
 setup de las interfaces

Configuración como router: 
 Routing
 NAT
 Forwarding
 Firewall

<br />

### OpenVPN en `sur`

En esta sección describo cómo configuro openvpn en modo cliente para que se conecte con `norte`

<br />

#### Instalo certificados como cliente de `norte`

Ya teníamos los certificados que preparamos y los he enviado a este equipo para instalarlos en el directorio `/etc/openvpn/client`. Preparo un subdirectorio donde irán las claves.

```console
# mkdir -p /etc/openvpn/cliente/keys/sur_cliente_de_norte
# cd /etc/openvpn/client/keys/sur_cliente_de_norte/
# tar xvfz /home/luis/sur_cliente_de_norte_keys.tgz
:
```

Ahora configuro el *servicio cliente de un Access Server*. Creo el fichero principal de configuración.

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
remote norte.dominio.com 1444
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
```


<br />

### Configuración del Switch TL-x08E




