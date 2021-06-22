---
title: "Pi-hole casero"
date: "2021-06-20"
categories: herramientas
tags: linux anuncios cortafuegos pihole whitelist adlist
excerpt_separator: <!--more-->
---

![logo pihole](/assets/img/posts/logo-pihole.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 

Pi-hole es un servidor de DNS que protege tus equipos de contenido no deseado, sin necesidad de instalar ningún software en los clientes de tu red. **Uno de los principales casos de uso es que haga de sumidero para la publicidad que inunda hoy en día las redes** 😅. Como lo oyes, puedes poner un pequeño PC con Linux y Pi-hole en tu red de casa para evitar que te llegue la mayoría de la publicidad mientras navegas. 

<br clear="left"/>
<!--more-->

<br>

En una Raspberry Pi 4B, he montado [Raspberry Pi OS](https://www.raspberrypi.org/software/operating-systems/) GNU/Linux 10 (buster) y el software [Pi-Hole](https://pi-hole.net). He realizado la instalación en mi casa, donde tengo un router de Movistar (pero valdría cualquier proveedor de internet). Desactivé el DNS/DHCP Server del router y pasé a usar ambos servicios en el Pi-Hole. Excluyendo la instalación de Raspbian (que no describo aquí) el proceso total es muy sencillo, tarda menos de diez minutos

Antes de empezar, las ventajas de Pi-hole, sacadas de su [propia](https://docs.pi-hole.net) web.

* Fácil de instalar: el instalador te guía por el proceso y tarda menos de diez minutos
* Resolutivo: la publicidad se bloquea no solo en navegador, sino también en aplicaciones móviles y televisores inteligentes
* Sensible: acelera la sensación de la navegación diaria gracias el almacenamiento en caché de las consultas DNS
* Ligero: se ejecuta sin problemas con unos requisitos mínimos de hardware y software, de hecho yo lo he instalado en una Pi4B pero puedes usar una menos potente.
* Robusto: una interfaz de línea de comandos de calidad garantizada para la interoperabilidad
* Inteligente: un panel de interfaz web con capacidad de respuesta para ver y controlar tu Pi-hole
* Versátil: puede funcionar opcionalmente como servidor DHCP, asegurando que todos los dispositivos estén protegidos automáticamente
* Escalable: capaz de gestionar cientos de millones de consultas si lo instalas en un servidor potente. 
* Moderno: bloquea los anuncios tanto en IPv4 como en IPv6
* Gratuito: software de código abierto, pero [funciona con DONACIONES, algo que te recomiendo hacer](https://docs.pi-hole.net). 


{% include showImagen.html 
      src="/assets/img/posts/pihole1.png" 
      caption="Arquitectura Pi-hole" 
      width="500px"
      %}

<br/>

¿Cómo funciona? pues de forma similar a un cortafuegos, los anuncios y los "rastreadores" se bloquean para todos los dispositivos que se encuentran en tu red casera. Cuando estos hagan una consulta a su DNS (servidor de nombres) verificará si debe bloquear dicho nombre porque lo tiene en su lista negra. Así de sencillo. 

<br/> 

### Instalación

Comprobé los [requisitos](https://docs.pi-hole.net/main/prerequisites/#supported-operating-systems) de Pi-hol y preparé el Hardware (Raspberry Pi), descargué el Sistema Operativo (Raspbian OS, documentado [aquí](https://www.raspberrypi.org/software/)), versión ([Raspberry Pi OS Lite](https://www.raspberrypi.org/software/operating-systems/), del 7 de Mayo de 2021) y lo copié a una memoria de 8GB usando [belenaEtcher](https://www.balena.io/etcher/).  

{% include showImagen.html
    src="/assets/img/posts/balenaEtcher2.png"
    caption=""
    width="500px"
    %}

<br/>

Tras hacer boot con la tarjeta preparada, terminé de configurar Raspian OS

```console
Login: pi
Password: raspbian

$ sudo raspi-config
- Cambio la contraseña del usuario 'pi'
- Cambio el hostname a 'pihole'
- Habilito SSH
- Localización -> Locale: es_ES.UTF-8 UTF-8  y lo marco como Default
- Localización -> Timezone -> Europe/Madrid
- Localización -> Keyboard -> Spanish
- Localización -> WLAN Country -> ES
- Advance -> Network -> Predictable Interface Name: Yes

```

Vía SSH sigo con la [instalación](https://docs.pi-hole.net/main/basic-install/) de Pi-hole:


* Conecto con la Raspberry Pi y ejecuto el script de instalación. 

```console
luis @ idefix ➜  ~  ssh pi@192.168.1.150

pi@pihole:~ $ curl -sSL https://install.pi-hole.net | bash

  [i] Root user check
  [i] Script called with non-root privileges
      The Pi-hole requires elevated privileges to install and run
      Please check the installer for any concerns regarding this requirement
      Make sure to download this script from a trusted source

  [✓] Sudo utility check

  [✓] Root user check

        .;;,.
        .ccccc:,.
         :cccclll:.      ..,,
          :ccccclll.   ;ooodc
           'ccll:;ll .oooodc
             .;cll.;;looo:.
                 .. ','.
                .',,,,,,'.
              .',,,,,,,,,,.
            .',,,,,,,,,,,,....
          ....''',,,,,,,'.......
        .........  ....  .........
        ..........      ..........
        ..........      ..........
        .........  ....  .........
          ........,,,,,,,'......
            ....',,,,,,,,,,,,.
               .',,,,,,,,,'.
                .',,,,,,'.
                  ..'''.

  [i] Update local cache of available packages...
  [✓] Update local cache of available packages

  [✓] Checking apt-get for upgraded packages... 23 updates available
  [i] It is recommended to update your OS after installing the Pi-hole!

  [i] Installer Dependency checks...
  [✓] Checking for dhcpcd5
  [i] Checking for git (will be installed)
  [✓] Checking for iproute2
  [✓] Checking for whiptail
  [i] Checking for dnsutils (will be installed)
  [i] Processing apt-get install(s) for: git dnsutils, please wait...
  :
  :
```

- Como Upstream **DNS Provider** elijo `custom` y configuro los de mi Proveedor (en el caso de Movistar son 80.58.61.250 y 80.58.61.254)
- Selecciono la **Lista StevenBlack**
- Selecciono que **bloquee anuncios sobre IPv4 e IPv6**.
- Indico que quiero **usar dirección IP fija** en la interfaz Ethernet `eth0`, luego lo voy a cambiar manualmente
- Indico que **Sí quiero el Web Admin Interface**
- Indico que **Sí quiero el Web Server**
- Indico que **Sí quiero activar el LOG**
- Selecciono el **modo privacy for FTL: Show Everything**

Una vez que termina me apunto datos importantes

- Configure your devices to use the Pi-hole as their DNS server: `192.168.100.150`
- View the web interface at: `http://192.168.100.150/admin`
- Your Admin Webpage login password is: `zaXxhC2K` (la cambiaré luego)

<br/>

### Configuración 

Actualizo el sistema y termino de configurar manualmente algunos aspectos

```console
 $ sudo apt update
 $ sudo apt upgrade -y
```

* Configuro dirección IP estática

```console
pi@pihole:~ $ sudo cat /etc/dhcpcd.conf
hostname
clientid
persistent
option rapid_commit
option domain_name_servers, domain_name, domain_search, host_name
option classless_static_routes
option interface_mtu
require dhcp_server_identifier
slaac private
#
#  LO SIGUIENTE ES MUY IMPORTANTE. OBLIGATORIO USAR SIEMPRE IP FIJA !!!!
#
interface eth0
        static ip_address=192.168.1.224/24
        static routers=192.168.1.1
        static domain_name_servers=80.58.61.250 80.58.61.254
```

* Desactivo completamente la WiFi y el BlueTooth (no los voy a usar). Nota que después de modificar este fichero debes hacer un `reboot`

```console
pi@pihole:~ $ sudo nano /boot/config.txt
:
:
dtoverlay=disable-wifi
dtoverlay=disable-bt
```

* Establezco la IP definitiva en dos ficheros

```console
pi@pihole:~ $ sudo nano /etc/pihole/local.list
192.168.1.224 pihole           <=== IMPORTANTE !!!!
192.168.1.224 pi.hole          <=== IMPORTANTE !!!!

pi@pihole:~ $ sudo nano /etc/pihole/setupVars.conf
PIHOLE_INTERFACE=eth0
IPV4_ADDRESS=192.168.1.224/24        <=== IMPORTANTE !!!!
IPV6_ADDRESS=
PIHOLE_DNS_1=80.58.61.250
PIHOLE_DNS_2=80.58.61.254
QUERY_LOGGING=true
INSTALL_WEB_SERVER=true
INSTALL_WEB_INTERFACE=true
LIGHTTPD_ENABLED=true
CACHE_SIZE=10000
WEBPASSWORD=8940218ea6c56cdafba82de7029e5fe0dcdcecc0dfbbe29e7579f88fe381a1d9
BLOCKING_ENABLED=true
```

* Reboot del equipo

```console
pi@pihole:~ $ sudo reboot
```

* Cambio la contraseña de administrador

```console
pi@pihole:~ $ sudo pihole -a -p
```

* Continúo con la administración vía Web

{% include showImagen.html 
      src="/assets/img/posts/pihole2.png" 
      caption="Arquitectura Pi-hole" 
      width="500px"
      %}

<br/>

{% include showImagen.html 
      src="/assets/img/posts/pihole3.png" 
      caption="Arquitectura Pi-hole" 
      width="500px"
      %}

<br/>

- Web interface: `http://192.168.1.224/admin`
- Admin Webpage password: `zaXxhC2K` (la cambiaré luego)

* Activo el DHCP Server
  
```config
   Settings -> DHCP -> Habilito DHCP Server
		From: 192.168.1.50
		To: 192.168.1.251
		Router: 192.168.1.1
		Domain: home.arpa
		Lease time in hours: 1
```

<br/> 

### Administración de Pi-hole

A partir de este momento: 

* Vía SSH `ssh pi@pihole.home.arpa` o bien `pi@192.168.1.224`. La contraseña es la que puse con raspi-config al principio. 

* Admin: [http://pihole.home.arpa/admin](http://pihole.home.arpa/admin)  (o bien Admin: http://192.168.1.224/admin)

* DNS server de mi red a partir de ahora: `192.168.1.224`

* DHCP server de mi red a partir de ahora: `192.168.1.224`

<br/> 

### Parametrización

El sistema ya debería estar operativo, sin embargo en mi caso he ido un poco más haya y realizado algunos cambios manualmente en los ficheros de configuración. 

```console
$ sudo cat /etc/dnsmasq.d/01-pihole.conf
addn-hosts=/etc/pihole/local.list
addn-hosts=/etc/pihole/custom.list
localise-queries
no-resolv
cache-size=10000
log-queries
log-facility=/var/log/pihole.log
local-ttl=2
log-async
server=80.58.61.250
server=80.58.61.254
interface=eth0
server=/use-application-dns.net/
dhcp-name-match=set:hostname-ignore,wpad
dhcp-name-match=set:hostname-ignore,localhost
dhcp-ignore-names=tag:hostname-ignore
```

```console
$ sudo cat /etc/dnsmasq.d/02-pihole-dhcp.conf
dhcp-authoritative
dhcp-range=192.168.1.50,192.168.1.251,1h
dhcp-option=option:router,192.168.1.1
dhcp-leasefile=/etc/pihole/dhcp.leases
domain=home.arpa
local=/home.arpa/   <=== Cambio posterior
```

* Un ejemplo de cómo asignar IP's vía DHCP de forma estática

```console
$ sudo cat /etc/dnsmasq.d/04-pihole-static-dhcp.conf
dhcp-host=52:22:01:AA:01:00,vlan100,192.168.1.1,router.home.arpa
dhcp-host=00:08:22:37:0E:A1,vlan100,192.168.1.2,estatico.home.arpa

dhcp-host=38:34:D3:3E:DA:31,vlan100,192.168.1.50,nodo1.home.arpa
dhcp-host=38:F9:34:B7:36:96,vlan100,192.168.1.51,nodo2.home.arpa
```

* Un ejemplo de cómo asignar Nombres DNS estáticos a direcciones IP.
  
```console
$ sudo cat /etc/pihole/custom.list
192.168.1.1 router.home.arpa
192.168.1.2 estatico.home.arpa
:
192.168.1.50 nodo1.home.arpa
192.168.1.51 nodo2.home.arpa
:
192.168.1.224 pihole.home.arpa
```

* Si modificas ficheros manualmente no olvides rearrancar pihole

```console
$ sudo pihole restartdns
```

<br/> 

### Adlists y Whitelists

Esta es mi configuración de ambos: 

* Adlists: Group Management -> Adlists

Tengo tres listas configuradas, empecé por la de StevenBlack y en updates posteriores se añadieron las dos siguientes.

```Config
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt		
https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
```

* Whitelists. Las he sacado de diferentes fuentes y estas son las que yo uso (y cómo las configuro desde cero)... 

```console

#
# REGEX: 

# Google Ads
pihole --white-regex "(\.|^)dartsearch\.net$"
pihole --white-regex "(\.|^)googleadservices\.com$"
pihole --white-regex "(\.|^)googleads\.g\.doubleclick\.net$"
pihole --white-regex "(\.|^)google-analytics\.com$"
pihole --white-regex "(\.|^)ad\.doubleclick\.net$"
pihole --white-regex "(\.|^)adservice\.google\.com$"
pihole --white-regex "(\.|^)adservice\.google\.es$"

# iOS - Ubiquiti WifiMan
# Symptom: Red warning stating ip-api.com cannot be reached.
pihole --white-regex "(\.|^)pro\.ip-api\.com$"
pihole --white-regex "(\.|^)reports\.crashlytics\.com$"

# Otras Regex
pihole --white-regex "(\.|^)symcb\.com$"

#
# Exactas: 

# iTunes
pihole -w itunes.apple.com
pihole -w s.mzstatic.com

# Apple-ID
pihole -w appleid.apple.com

# NVIDIA GeForce
pihole -w gfwsl.geforce.com 

# GooglePay android updates
pihole -w android.clients.google.com

# Captive-portal tests
# These domains are checked by the operating systems when connecting via wifi, and if they don't get the response they expect, they may try to open a wifi login page or similar as they believe they are located behind a captive portal.
# Android/Chrome
pihole -w connectivitycheck.android.com android.clients.google.com clients3.google.com connectivitycheck.gstatic.com 

# Windows/Microsoft
pihole -w msftncsi.com www.msftncsi.com ipv6.msftncsi.com

# iOS/Apple
pihole -w captive.apple.com gsp1.apple.com www.apple.com www.appleiphonecell.com

# Google Maps and other Google services
pihole -w clients4.google.com 
pihole -w clients2.google.com

# YouTube history
pihole -w s.youtube.com 
pihole -w video-stats.l.google.com

# Google Play
# pihole -w android.clients.google.com

# Google Keep
pihole -w reminders-pa.googleapis.com firestore.googleapis.com

# Gmail (Google Mail)
pihole -w googleapis.l.google.com

# Google Chrome (to update on ubuntu)
pihole -w dl.google.com

# Microsoft (Windows, Office, Skype, etc)
# Windows uses this to verify connectivity to Internet
pihole -w www.msftncsi.com

# Microsoft Web Pages (Outlook, Office365, Live, Microsoft.com 685...)
pihole -w outlook.office365.com products.office.com c.s-microsoft.com i.s-microsoft.com login.live.com login.microsoftonline.com 

# Backup bitlocker recovery key to Microsoft account
pihole -w g.live.com

# Microsoft Store (Windows Store)
pihole -w dl.delivery.mp.microsoft.com geo-prod.do.dsp.mp.microsoft.com displaycatalog.mp.microsoft.com

# Windows 10 Update
pihole -w sls.update.microsoft.com.akadns.net fe3.delivery.dsp.mp.microsoft.com.nsatc.net

# Xbox Live
# This domain is used for sign-ins, creating new accounts, and recovering existing Microsoft accounts on your (confirmed by Microsoft)
pihole -w clientconfig.passport.net 

# These domains are used for Xbox Live Achievements (confirmed by Microsoft)
pihole -w v10.events.data.microsoft.com
pihole -w v20.events.data.microsoft.com

# Used for Xbox Live Messaging (post)
pihole -w client-s.gateway.messenger.live.com

# There are several domains discovered initially on Reddit 385 and /r/xboxone 319, which were also confirmed by Microsoft as being required by Xbox Live for full functionality.
pihole -w xbox.ipv6.microsoft.com device.auth.xboxlive.com www.msftncsi.com title.mgt.xboxlive.com xsts.auth.xboxlive.com title.auth.xboxlive.com ctldl.windowsupdate.com attestation.xboxlive.com xboxexperiencesprod.experimentation.xboxlive.com xflight.xboxlive.com cert.mgt.xboxlive.com xkms.xboxlive.com def-vef.xboxlive.com notify.xboxlive.com help.ui.xboxlive.com licensing.xboxlive.com eds.xboxlive.com www.xboxlive.com v10.vortex-win.data.microsoft.com settings-win.data.microsoft.com

# Skype
# See the GitHub Topic 596 on these domains.
pihole -w s.gateway.messenger.live.com client-s.gateway.messenger.live.com ui.skype.com pricelist.skype.com apps.skype.com m.hotmail.com 

# Microsoft Office
# Reddit link - r/pihole - MS Office issues 440
pihole -w officeclient.microsoft.com

# Otros
pihole -w mobile.pipe.aria.microsoft.com
pihole -w self.events.data.microsoft.com
pihole -w pixel.wp.com
pihole -w analytics.google.com

```

<br/>

### Actualizaciones futuras. 

En el futuro si quiero actualizar Raspbian OS y/o Pi-hole realizo lo siguiente: 

* Actualización de Raspbian OS

```console
$ sudo apt-get update
$ sudo apt-get upgrade -y 
$ sudo apt-get dist-upgrade -y 
$ sudo apt autoremove -y
```

* Actualización de Pi-hole
  
```console
$ pihole -up
```

<br/>

### Referencias a estudiar

Encontré esta herramienta que es interesante estudiar... Link https://github.com/jessedp/pihole5-list-tool


