---
title: "RaspberryPi v1 como Servidor DNS y DHCP"
date: "2015-02-21"
categories: apuntes
tags: linux nuc
excerpt_separator: <!--more-->
---

Un apunte rápido sobre cómo configurar mi antigua Raspberry Pi "1" como DNS Server y DHCP Server. Ambas son funciones críticas en la red "casera de todo hacker", así que he decidido delegarle esta función. Mucho mejor que tener la Pi1 guardada en un cajón.

{% include showImagen.html
    src="/assets/img/original/RaspDD.jpg"
    caption="RaspDD"
    width="600px"
    %}

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**AVISO**: Todas las direcciones IP y nombres de dominio o de hosts que utilizo son ejemplos que no deberías copiar tal cual, úsalo cómo referencia.

[/dropshadowbox]

{% include showImagen.html
    src="/assets/img/original/"
    caption="Raspbian"
    width="600px"
    %}
- Realizo el primer boot y la configuro siguiendo el asistente. La dejo en modo consola, sin gráficos, con el teclado, locales, timezone preparados para Madrid y Castellano...
- Puedes cambiar múltiples parámetros con
    
    ```
    sudo raspi-config
    ```
    

 

### Dirección IP estática

- Entro por SSH y paso a cambiar la configuración para usar una dirección IP Estática. Edito el fichero /etc/network/interfaces y /etc/resolv.conf (este último de momento apuntando al DNS Server que tengo ahora mismo activo).

obelix ~ $ ssh -l pi 192.168.1.XXX  (XXX= Dirección que tenga ahora y que recibió por DHCP)
:
pi@raspberrypi ~ $ sudo su -
root@raspberrypi:~#
root@raspberrypi:~# nano /etc/network/interfaces
:
root@raspberrypi:~# nano /etc/resolv.conf

auto lo

iface lo inet loopback
iface eth0 inet static
 address 192.168.1.253   <== IP de la Pi1, que será en breve el DNS/DHCP Server casero
 netmask 255.255.255.0
 gateway 192.168.1.1

#allow-hotplug wlan0
#iface wlan0 inet manual
#wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
#iface default inet dhcp

- En versiones más modernas hay que modificar el fichero /etc/dhcp/dhcpcd.conf

interface eth0
static ip_address=192.168.1.253/24
static routers=192.168.1.1
static domain_name_servers=127.0.0.1

- Fichero resolv.conf

domain parchis.org
search parchis.org
nameserver 192.168.1.1   <== Temporalmente hasta que terminemos y lo cambiaré a 127.0.0.1

- Es opcional pero a mi me gusta cambiarle el nombre al host, así que modifico los ficheros /etc/hostname y /etc/hosts

apodix

127.0.0.1   apodix.parchis.org apodix localhost localhost.localdomain
::1     localhost ip6-localhost ip6-loopback
fe00::0     ip6-localnet
ff00::0     ip6-mcastprefix
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters

- Rearranco la Raspberry

root@raspberrypi:~#
root@raspberrypi:~# reboot

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**NOTA**: Al hacer reboot y conectar de nuevo vía SSH estoy comprobando que la dirección estática está funcionando correctamente, es importante :-).

[/dropshadowbox]

### Instalación del software

- Vuelvo a entrar por SSH y lo primero que hago es actualizar a lo último, al tratarse de un "derivado" de Debian básicamente hacemos un update y luego un upgrade

obelix ~ $ ssh -l pi 192.168.1.253  (Dirección IP estática)
:
pi@raspberrypi ~ $ sudo su -
root@raspberrypi:~#
root@raspberrypi:~# apt-get update
root@raspberrypi:~# apt-get upgrade

- Instalo los servidores DHCP y DNS

root@raspberrypi:~# apt-get install -y isc-dhcp-server bind9 bind9-doc dnsutils

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**NOTA**: Tras la instalación intenta arrancar el DHCP Server, no se a qué vienen tantas prisas, da un error obvio porque todavía no está configurado :-)

[/dropshadowbox]

### Configuración DHCP

- Configuro DHCP, edito los ficheros /etc/default/isc-dhcp-server donde se indica el interfaz del servicio y /etc/dhcp/dhcpd.conf donde se configura el servicio.

INTERFACES="eth0"

# dhcpd.conf
#
ddns-update-style none;
authoritative;
option opch code 240 = text;

#
# Definicion de las subnets (scopes)
#
shared-network lan {
    #------------------------------------------------------#
    #                                                      #
    #  Interface activa. Ver /etc/default/isc-dhcp-server  #
    #  INTERFACES="eth0"                                   #
    #                                                      #
    #------------------------------------------------------#
    subnet 192.168.1.0 netmask 255.255.255.0 {
        option routers 192.168.1.1;
        option subnet-mask 255.255.255.0;
        option domain-name "parchis.org";
        option domain-name-servers 192.168.1.253;
        option interface-mtu 1496;

        allow bootp;
        allow booting;

        # Pool

        pool {
             range 192.168.1.150 192.168.1.190;
        }
    }
}

#####################
###
### Ejemplo de un host al que se le asigna una direccion especifica
###
#####################

host equipo1 {
    hardware ethernet 12:34:56:78:aa:bb;
    fixed-address equipo1.parchis.org;
}

#####################
###
### Ejemplo de DECO del servicio Movistar TV
###
#####################

host deco-cocina {
    hardware ethernet 4c:9e:ff:11:22:33;
    fixed-address 192.168.1.200;
    option domain-name-servers 172.26.23.3;
    option opch ":::::239.0.2.10:22222:v6.0:239.0.2.30:22222";
}

### Configuración DNS

Voy a configurar el DNS server para que haga dos cosas. La primera es que sirva un dominio interno privado (resuelva nombres privados y entregue direcciones de mi intranet). La segunda es que se convierta en el DNS server de la intranet, delegandole a él ir a buscar las respuestas a internet y hacer "caching":

- /etc/bind/named.conf: Fichero principal del DNS Server, no hace falta modificarlo.
    
- /etc/bind/named.conf.options: Opciones generales del DNS Server, lo modifico para indicar el comportamiento general del servicio.
    

/*
* Fichero named.conf.options de ejemplo
*/
 
/*
* Equipos en los que confio, 
*/
acl "trusted" {
    127.0.0.0/8;
    192.168.1/24;
};
 
options {
        /*
         * Directorio donde se almacenará la caché
         */
        directory "/var/cache/bind";
 
        /*
         * Direcciones en las que escucho
         */
        listen-on-v6 { none; }; 
        listen-on { 127.0.0.1; };
        listen-on { 192.168.1.253; };
 
         /*
          * Equipos en los que confio, que podrán hacerme consultas
          */
         allow-query {
             trusted;
         };

         /*
          * Hago caching para los "trusted"
          */
         allow-query-cache {
             trusted;
         };

         /*
          * Permito recursión solo a los "trusted"
          */
         allow-recursion {
             trusted;
         };
  
         /*
          * Deshabilito transferencia de zonas por defecto
          */
         allow-transfer {
             none;
         };
 
         /*
          * Deshabilito updates por defecto
          */
         allow-update {
             none;
         };
 
         /*
          * Opciones para dnssec
          */
         dnssec-enable yes;
         dnssec-validation auto; 

         auth-nxdomain no;    # conform to RFC1035
};

- /etc/bind/named.conf.local: Dominio(s)/Zona(s) privado(s).

   allow-recursion {
      /* Only trusted addresses are allowed to use recursion. */
      trusted;
   };
 
   recursion yes;
  
   // Para peticiones desde la intranet hacia DNS de Movistar
   //
   // Traslado al dns server 172.26.23.3 todas las consulatas que me
   // hagan que terminen en cualquiera de estos dos dominios
   //
   zone "svc.imagenio.telefonica.net" in {
        type forward;
        forwarders { 172.26.23.3; };
        forward only;
   };
   zone "tv.movistar.es" in {
        type forward;
        forwarders { 172.26.23.3; };
        forward first;
   };
 
  /**
   *   Zonas privadas
   */
 
  zone "parchis.org" {
    notify no;
    type master;
    file "/var/lib/bind/parchis.org";
    allow-transfer { localhost; };
    allow-query { any; };
  };
 
  zone "1.168.192.in-addr.arpa" {
    notify no;
    type master;
    file "/var/lib/bind/1.168.192";
    allow-transfer { localhost; };
    allow-query { any; };
  };

- /etc/bind/named.conf.default.zones: Zonas por defecto del servidor. No hace falta modificar este fichero

Zona privada para la intranet: parchis.org

;
; Fichero para zona parchis.org
;
$TTL 3D
@       IN      SOA     ns1.parchis.org. luis.parchis.org.  (
                                      2015031901 ; Serial
                                      28800      ; Refresh
                                      14400      ; Retry
                                      3600000    ; Expire
                                      86400 )    ; Minimum
                TXT            "NS de Parchis"
                NS          ns1.parchis.org.
;
localhost       A               127.0.0.1
apodix          A               192.168.1.253
ns1             A               192.168.1.253
cortafuegix     A               192.168.1.1

; Servidor de aplicaciones dockerizadas
apps            A               192.168.1.100

; Equipos adicionales en la red
panoramix       A               192.168.1.150
                HINFO           "QNAPTS569Pro" "QNAP TS-569 Pro en el garaje"
luispa-mac      A               192.168.1.151
                HINFO           "MacbookPro" "MBP6.2 de Luis"
rasp-dormitorio A               192.168.1.152
                HINFO           "RaspberryPi" "Raspberry Pi 2 Model B v1.1"
deco-movistar   A               192.168.1.200
                HINFO           "Movistar TV" "Zyxel STB-2112T Nano V2"
switch          A               192.168.1.254
                HINFO           "Switch" "Switch con soporte de VLANs"

Resolución inversa

;
; Fichero de la zona inversa parchis.org
;
$TTL 3D
@       IN      SOA     ns1.parchis.org. luis.parchis.org.  (
                                      2015031901 ; Serial
                                      28800      ; Refresh
                                      14400      ; Retry
                                      3600000    ; Expire
                                      86400 )    ; Minimum
                NS      ns1.parchis.org.

1       PTR     cortafuegix.parchis.org.
253     PTR     ns1.parchis.org.
150     PTR     panoramix.parchis.org.
151     PTR     luispa-mac.parchis.org.
152     PTR     rasp-dormitorio.parchis.org.
200     PTR     deco-movistar.parchis.org.
254     PTR     switch.parchis.org.

A partir de ahora hay que configurar a todos los clientes (incluyendose ella misa) para que consulten a la Pi1 los nombres DNS.

### Configuración de los clientes

Una vez que tenemos la configuración del servidor DNS hay que cambiar la de los clientes (INCLUIDA la del propio servidor), de modo que todo el mundo consulte a este nuevo servidor DNS en la Raspberry Pi.

- La Raspberry (consulta a su propio servicio DNS)

domain parchis.org
search parchis.org
nameserver 127.0.0.1

- Clientes de la Intranet

domain parchis.org
search parchis.org
nameserver 192.168.1.253

### Arranque de los servicios

Para activar los servicios te vale con rearrancar la Raspberry o bien arrancarlos ahora de forma manual.

root@raspberrypi:~# /etc/init.d/bind9 restart

root@raspberrypi:~# /etc/init.d/isc-dhcp-server restart

### Comandos útiles

- **Comprobar integridad configuración DNS**. Ejecutar el comando siguiente en la Pi y si no da ningún errror entonces es que vamos bien :-)

root@raspberrypi:~# / named-checkconf

- **Comprobar que nuestro DNS Server funciona**. Ejecutar el comando siguiente en cualquier cliente de la red (o incluso en la Pi), cualquiera que tenga su fichero resolv.conf apuntando a la Raspberry Pi. Fíjate que la primera consulta tarda 625 milisegundos y la segunda solo 3. La primera vez tuvo que ir a internet a por la respuesta y la segunda ya la tenía en cache.

root@apodix:~# dig rediris.es | grep -E '(NS|Query)'
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 5, ADDITIONAL: 9
;; ANSWER SECTION:
rediris.es.     85970   IN  NS  sun.rediris.es.
rediris.es.     85970   IN  NS  chico.rediris.es.
rediris.es.     85970   IN  NS  scsnms.switch.ch.
rediris.es.     85970   IN  NS  ns02.fccn.pt.
rediris.es.     85970   IN  NS  ns15.communitydns.net.
;; Query time: 625 msec

root@apodix:~# dig rediris.es | grep Query
;; Query time: 3 msec

- Comprobar el espacio libre. Vemos que con una tarjeta SD de 8GB nos ha quedado espacio de sobra:

root@raspberrypi:~# df -h
S.ficheros     Tamaño Usados  Disp Uso% Montado en
rootfs           7,2G   2,5G  4,4G  37% /
/dev/root        7,2G   2,5G  4,4G  37% /
devtmpfs         214M      0  214M   0% /dev
tmpfs             44M   244K   44M   1% /run
tmpfs            5,0M      0  5,0M   0% /run/lock
tmpfs             88M      0   88M   0% /run/shm
/dev/mmcblk0p1    56M    15M   42M  26% /boot

### NTP

- He añadido esta sección porque quiero activar el cliente NTP en este equipo. El proceso es el siguiente:

:
pi@raspberrypi ~ $ sudo su -
root@raspberrypi:~#
root@raspberrypi:~# apt-get update
root@raspberrypi:~# apt-get upgrade
root@raspberrypi:~# apt-get install -y ntpdate

El servicio NTPD se arranca y a partir de aquí podemos comprobar si ha alcanzado el estado de Stratum 3 con los comandos siguientes:

# ntpq -c readvar
# ntpq -c peers

### Enlaces

{% include showImagen.html
    src="/assets/img/original/"
    caption="artículo"
    width="600px"
    %}
