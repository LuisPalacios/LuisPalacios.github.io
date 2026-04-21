---
title: "Pi-hole casero"
date: "2021-06-20"
categories: ["herramientas"]
tags: ["linux","anuncios","cortafuegos","pihole","whitelist","adlist"]
draft: false
cover:
  image: "/img/posts/logo-pihole.svg"
  hidden: true
---

<img src="/img/posts/logo-pihole.svg" alt="logo pihole" width="150px" height="150px" style="float:left; padding-right:25px"  />

Pi-hole es un servidor DNS (y DHCP) que protege tus equipos de contenido no deseado, sin necesidad de instalar ningún software en los clientes de tu red. **Su caso de uso es que haga de sumidero para la publicidad que inunda hoy en día las redes** 😅. Como lo oyes, un pequeño PC con Linux y Pi-hole en tu red de casa para evitar que te llegue mogollón de publicidad mientras navegas.

<br clear="left"/>
<!--more-->

<br>

En una Raspberry Pi 4B, he montado [Raspberry Pi OS](https://www.raspberrypi.org/software/operating-systems/) GNU/Linux 10 (buster) y [Pi-Hole](https://pi-hole.net). He realizado la instalación en mi casa, donde tengo un router de Movistar (pero valdría cualquier proveedor de internet). Desactivé el DNS/DHCP Server del router y pasé a usar ambos servicios en el Pi-Hole. Excluyendo la instalación de Raspbian, el proceso total es muy sencillo, tarda menos de diez minutos

Antes de empezar, ventajas de Pi-hole, sacadas de su [propia](https://docs.pi-hole.net) web.

- Fácil de instalar: el instalador te guía por el proceso y tarda menos de diez minutos
- Resolutivo: la publicidad se bloquea no solo en navegador, sino también en aplicaciones móviles y televisores inteligentes
- Sensible: acelera la sensación de la navegación diaria gracias el almacenamiento en caché de las consultas DNS
- Ligero: se ejecuta sin problemas con unos requisitos mínimos de hardware y software, de hecho yo lo he instalado en una Pi4B pero puedes usar una menos potente.
- Robusto: una interfaz de línea de comandos de calidad garantizada para la interoperabilidad
- Inteligente: un panel de interfaz web con capacidad de respuesta para ver y controlar tu Pi-hole
- Versátil: puede funcionar opcionalmente como servidor DHCP, asegurando que todos los dispositivos estén protegidos automáticamente
- Escalable: capaz de gestionar cientos de millones de consultas si lo instalas en un servidor potente.
- Moderno: bloquea los anuncios tanto en IPv4 como en IPv6
- Gratuito: software de código abierto, [funciona con DONACIONES, algo que te recomiendo hacer](https://docs.pi-hole.net).

<div class="image-box">
  <img src="/img/posts/2021-06-20-pihole-casero-02.png" alt="Arquitectura Pi-hole" width="500px" />
  <div class="image-caption">Arquitectura Pi-hole</div>
</div>

<br/>

¿Cómo funciona? pues de forma similar a un cortafuegos, los anuncios y los "rastreadores" se bloquean para todos los dispositivos que se encuentran en tu red casera. Cuando hagan una consulta al DNS de Pi-hole bloqueará los nombres que tenga en su lista negra.

<br/>

### Instalación

Comprobé los [requisitos](https://docs.pi-hole.net/main/prerequisites/#supported-operating-systems) de Pi-hole y preparé el Hardware (Raspberry Pi), descargué el Sistema Operativo (Raspbian OS, documentado [aquí](https://www.raspberrypi.org/software/)), versión ([Raspberry Pi OS Lite](https://www.raspberrypi.org/software/operating-systems/), del 7 de Mayo de 2021) y lo copié a una memoria de 8GB usando [belenaEtcher](https://www.balena.io/etcher/).

<div class="image-box">
  <img src="/img/posts/2021-06-20-pihole-casero-01.png" alt="Balena Etcher" width="500px" />
  <div class="image-caption">Balena Etcher</div>
</div>

<br/>

Tras el boot terminé de configurar Raspian OS

```shell
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

Vía SSH sigo con la [instalación](https://docs.pi-hole.net/main/basic-install/) de Pi-hole. Conecto con la dirección IP que ha recibido desde el DHCP Server que tengo en mi red (Router del proveedor) y que sustituiré más adelante, una vez asigne una IP fija.

- Conecto con la Raspberry Pi y ejecuto el script de instalación.

```shell
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

- Configure your devices to use the Pi-hole as their DNS server: `192.168.1.150`
- View the web interface at: `http://192.168.1.150/admin`
- Your Admin Webpage login password is: `zaXxhC2K` (la cambiaré luego)

<br/>

### Configuración

Actualizo el sistema y termino de configurar manualmente algunos aspectos

```shell
 sudo apt update
 sudo apt upgrade -y
```

- Configuro dirección IP estática, decido poner la `.224` (`192.168.1.224`)

```shell
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
#  Hasta ahora teníamos la .150 que es la que me asignó DHCP y que pedí
#  quedara como fija, pero fue solo para que me creara las líneas siguientes.
#  Pongo aquí la IP definitiva:
#
interface eth0
        static ip_address=192.168.1.224/24
        static routers=192.168.1.1
        static domain_name_servers=80.58.61.250 80.58.61.254
```

- Desactivo completamente la WiFi y el BlueTooth (no los voy a usar).

```shell
pi@pihole:~ $ sudo nano /boot/config.txt
:
:
dtoverlay=disable-wifi
dtoverlay=disable-bt
```

- Establezco la IP definitiva en dos ficheros

```shell
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

- Reboot del equipo

```shell
pi@pihole:~ $ sudo reboot
```

- Una vez que arranca, entro por SSH y cambio la contraseña de administrador de PiHole

```shell
pi@pihole:~ $ sudo pihole -a -p
```

- Continúo con la administración vía Web

<div class="image-box">
  <img src="/img/posts/2021-06-20-pihole-casero-03.png" alt="Login en Pi-hole" width="500px" />
  <div class="image-caption">Login en Pi-hole</div>
</div>

<br/>

<div class="image-box">
  <img src="/img/posts/2021-06-20-pihole-casero-04.png" alt="Dashboard de Pi-hole" width="500px" />
  <div class="image-caption">Dashboard de Pi-hole</div>
</div>

<br/>

- Web interface: `http://192.168.1.224/admin`

- IMPORTANTE: Desactivo el DHCP Server que tenía antes en la misma red LAN. Estaba configurado en el router de Movistar, accedí a su configuración y lo desactivé.

- Activo el DHCP Server de Pi-Hole

```config
   Settings -> DHCP -> Habilito DHCP Server
  From: 192.168.1.50
  To: 192.168.1.220
  Router: 192.168.1.1
  Domain: home.arpa
  Lease time in hours: 1
```

<br/>

### Administración de Pi-hole

A partir de este momento:

- Vía SSH `ssh pi@pihole.home.arpa` o bien `pi@192.168.1.224`. La contraseña es la que puse con raspi-config al principio.

- Admin: [http://pihole.home.arpa/admin](http://pihole.home.arpa/admin)  (o bien Admin: <http://192.168.1.224/admin>)

- DNS server de mi red a partir de ahora: `192.168.1.224`

- DHCP server de mi red a partir de ahora: `192.168.1.224`

<br/>

### Parametrización

El sistema ya debería estar operativo, sin embargo en mi caso he ido un poco más allá y realizado algunos cambios manualmente en los ficheros de configuración.

```shell
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

```shell
$ sudo cat /etc/dnsmasq.d/02-pihole-dhcp.conf
dhcp-authoritative
dhcp-range=192.168.1.50,192.168.1.251,1h
dhcp-option=option:router,192.168.1.1
dhcp-leasefile=/etc/pihole/dhcp.leases
domain=home.arpa
local=/home.arpa/   <=== Cambio posterior
```

- Un ejemplo de cómo asignar IP's vía DHCP de forma estática

```shell
$ sudo cat /etc/dnsmasq.d/04-pihole-static-dhcp.conf
dhcp-host=52:22:01:AA:01:00,vlan100,192.168.1.1,router.home.arpa
dhcp-host=00:08:22:37:0E:A1,vlan100,192.168.1.2,estatico.home.arpa

dhcp-host=38:34:D3:3E:DA:31,vlan100,192.168.1.50,nodo1.home.arpa
dhcp-host=38:F9:34:B7:36:96,vlan100,192.168.1.51,nodo2.home.arpa
```

- Un ejemplo de cómo asignar Nombres DNS estáticos a direcciones IP.

```shell
$ sudo cat /etc/pihole/custom.list
192.168.1.1 router.home.arpa
192.168.1.2 estatico.home.arpa
:
192.168.1.50 nodo1.home.arpa
192.168.1.51 nodo2.home.arpa
:
192.168.1.224 pihole.home.arpa
```

- Si modificas ficheros manualmente no olvides rearrancar pihole

```shell
sudo pihole restartdns
```

<br/>

### Adlists y Whitelists

Esta es mi configuración de ambos:

- Adlists: Group Management -> Adlists

Tengo tres listas configuradas, empecé por la de StevenBlack y en updates posteriores se añadieron las dos siguientes.

```Config
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt
https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
```

```shell
sudo pihole -g
```

- Whitelists. Las he sacado de diferentes fuentes y estas son las que yo uso (y cómo las configuro desde cero)...

```shell

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

# Apple
# Aquí tienes la lista completa publicada por Apple:
# https://support.apple.com/en-us/HT210060

# Apple varios REGEX
pihole --white-regex *.apps.apple.com *.amazonaws.com *.cdn-apple.com *.digicert.com deimos3.apple.com *.symcb.com *.symcd.com

# Apple varios Exacta
pihole -w www.appleiphonecell.com gnf-mdn.apple.com gnf-mr.apple.com  gsp1.apple.com swpost.apple.com ocsp.verisign.net

# Apple Device setup
pihole -w albert.apple.com captive.apple.com gs.apple.com humb.apple.com static.ips.apple.com sq-device.apple.com tbsc.apple.com time-ios.apple.com time.apple.com time-macos.apple.com

# Apple Device management
pihole --white-regex *.push.apple.com
pihole -w deviceenrollment.apple.com deviceservices-external.apple.com gdmf.apple.com identity.apple.com iprofiles.apple.com mdmenrollment.apple.com setup.icloud.com vpp.itunes.apple.com

# Apple Apple Business Manager and Apple School Manager
pihole --white-regex *.business.apple.com *.school.apple.com *.itunes.apple.com *.mzstatic.com *.vertexsmb.com
pihole -w appleid.cdn-apple.com idmsa.apple.com api.ent.apple.com api.edu.apple.com statici.icloud.com www.apple.com upload.appleschoolcontent.com ws-ee-maidsvc.icloud.com

# Apple Business Essentials device management
pihole -w axm-adm-enroll.apple.com axm-adm-mdm.apple.com axm-adm-scep.apple.com axm-app.apple.com icons.axm-usercontent-apple.com
pihole --white-regex *.apple-mapkit.com

# Apple Classroom and Schoolwork
pihole -w s.mzstatic.com play.itunes.apple.com ws-ee-maidsvc.icloud.com ws.school.apple.com pg-bootstrap.itunes.apple.com cls-iosclient.itunes.apple.com cls-ingest.itunes.apple.com

# Apple macOS, iOS, iPadOS, watchOS, and tvOS
pihole -w appldnld.apple.com configuration.apple.com gdmf.apple.com gg.apple.com gs.apple.com ig.apple.com mesu.apple.com ns.itunes.apple.com oscdn.apple.com  osrecovery.apple.com skl.apple.com swcdn.apple.com swdist.apple.com swdownload.apple.com swscan.apple.com updates-http.cdn-apple.com updates.cdn-apple.com xp.apple.com

# App Store
pihole --white-regex *.itunes.apple.com *.apps.apple.com *.mzstatic.com
pihole -w itunes.apple.com ppq.apple.com

# Apple Carrier updates
pihole -w appldnld.apple.com appldnld.apple.com.edgesuite.net itunes.com itunes.apple.com updates-http.cdn-apple.com updates.cdn-apple.com

# Apple Content caching
pihole -w lcdn-registration.apple.com suconfig.apple.com xp-cdn.apple.com lcdn-locator.apple.com serverstatus.apple.com

# Apple App features
pihole -w api.apple-cloudkit.com
pihole --white-regex *.appattest.apple.com

# Apple Feedback Assistant
pihole -w bpapi.apple.com cssubmissions.apple.com fba.apple.com

# Apple diagnostics
pihole -w diagassets.apple.com

# Apple Domain Name System resolution
pihole -w doh.dns.apple.com

# Apple Certificate validation
pihole -w certs.apple.com crl.apple.com crl.entrust.net crl3.digicert.com crl4.digicert.com ocsp.apple.com ocsp.digicert.cn ocsp.digicert.com ocsp.entrust.net ocsp2.apple.com valid.apple.com

# Apple ID
pihole -w appleid.apple.com appleid.cdn-apple.com idmsa.apple.com  gsa.apple.com

# Apple iCloud
pihole --white-regex *.apple-cloudkit.com *.apple-livephotoskit.com *.cdn-apple.com *.gc.apple.com *.icloud.com *.icloud.apple.com *.icloud-content.com *.iwork.apple.com
pihole -w mask-api.icloud.com

# Apple Siri and Search
pihole -w guzzoni.apple.com
pihole --white-regex *.smoot.apple.com

# Apple Associated Domains
pihole -w app-site-association.cdn-apple.com app-site-association.networking.apple

# Apple Tap to Pay on iPhone
pihole -w pos-device.apple.com humb.apple.com phonesubmissions.apple.com

# Apple Additional content
pihole -w audiocontentdownload.apple.com devimages-cdn.apple.com download.developer.apple.com playgrounds-assets-cdn.apple.com playgrounds-cdn.apple.com sylvan.apple.com
```

<br/>

### iCloud Private Relay

PiHole bloquea por defecto el acceso a los dominios `mask.icloud.com` y `mask-h2.icloud.com`. El objetivo es **bloquear** el acceso al servicio **iCloud Private Relay** para prevenir que los dispositivos de Apple se salten PiHole a la torera. El equipo de PiHole lo ha implementado siguiendo las recomendaciones de la propia empresa Apple (puedes consultarlo [aquí](https://developer.apple.com/support/prepare-your-network-for-icloud-private-relay))

Si deseas permitir a tus dispositivos Apple usar **iCloud Private Relay** y esquivar por completo a PiHole debes configurar `BLOCK_ICLOUD_PR=false` en el fichero `/etc/pihole/pihole-FTL.conf` y rearrancar pihole-FTL (`sudo service pihole-FTL restart`).

<br/>

### Servidor DNS recursivo

Es posible configurar Pi-Hole como un servidor DNS recursivo. Un servidor DNS recursivo recorrerá la ruta completa (empezando por `root`) del nombre que le piden. Es decir, recorrerá camino dentro del dominio que le piden a través de Internet para entregar la respuesta a la petición. No usará ningún DNS Server intermediario, será más lento al principio pero evita posibles suplantaciones.

Si quieres conseguir que tu servidor Pi-Hole actúe además como un Servidor DNS recursivo entonces necesitas montar un software adicional. Uno recomendado es `unbound`, un servidor DNS recursivo seguro de código abierto desarrollado principalmente por NLnet Labs, VeriSign Inc, Nominet y Kirei.

En el siguiente enlace tienes explicado todo el proceso para configurarlo

- [Pi-hole as All-Around DNS Solution with Unbound](https://docs.pi-hole.net/guides/dns/unbound/)

<br/>

### Actualizaciones futuras

En el futuro si quiero actualizar Raspbian OS y/o Pi-hole realizo lo siguiente:

- Actualización de Raspbian OS

```shell
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt autoremove -y
```

- Actualización de Pi-hole

```shell
pihole -up
```

<br/>

### Referencias

- Hilo Interesante: [Commonly Whitelisted Domains](https://discourse.pi-hole.net/t/commonly-whitelisted-domains/212/73?page=4)
- Herramienta curiosa a estudiar: [pihole5-list-tool](https://github.com/jessedp/pihole5-list-tool)
