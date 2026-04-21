---
title: "Router con PiHole 6"
date: "2025-03-08"
categories: ["administración"]
tags: ["domótica","networking","avanzado","linux","pve","proxmox","ubuntu","dhcp","dns","dnsmasq","pihole","adlist"]
draft: false
cover:
  image: "/img/posts/logo-piholednsmasq.svg"
  hidden: true
---

<img src="/img/posts/logo-piholednsmasq.svg" alt="Logo Pihole Router" width="150px" style="float:left; padding-right:25px"  />

Hace un par de meses moví el servicio DHCP y DNS a mi Router linux de casa y dejé el servicio de Pi-Hole 5 en otra máquina virtual. A pesar de funcionar perfecto me topé con una pega, el troubleshooting desde PiHole es complicado, porque todas las peticiones DNS las resuelve el router y en PiHole no se ve nada, así que he decidido volver a cambiar el diseño.

En este apunte describo cómo instalo Pi-Hole 6 en mi router Linux para que ofrezca DNS, DHCP (con dnsmasq) y sumidero de la publicidad. Esto conlleva deshacer la instalación nativa de dnsmasq.

<br clear="left"/>
<!--more-->

## Introducción

En mi "montaje" anterior tenía el [Servidor DHCP y DNS]({{< relref "2024-12-26-dnsmasq.md" >}}) con dnsmasq en mi router y un Pi-Hole 5 en una máquina virtual como sumidero de la publicidad. En este apunte evoluciono a un montaje distinto, **instalo Pi-Hole 6 en el router, sustituyendo el dnsmasq y evoluciono toda la configuración anterior**, de modo que a partir de ahora Pi-Hole 6 hace todo: DNS, DHCP y sumidero de publicidad:

<div class="image-box">
  <img src="/img/posts/2025-03-08-router-pihole-01.svg" alt="Router con PiHole" width="400px" />
  <div class="image-caption">Router con PiHole</div>
</div>

## Evolución a PiHole 6

El proceso es delicado, `cortafuegix` está en producción... Tengo que evitar que el `dnsmasq` entre en conflicto con la instancia que Pi-hole trae incorporada, migrar las configuraciones y evitar que el propio router tenga problemas de "resolución" durante el proceso. He seguido estos pasos:

- Salvo toda la configuración de `dnsmasq`
- Copia de seguridad de `cortafuegix`
- Cambio Netplan en `cortafuegix` para que sus consultas vayan al `pihole` externo durante el proceso de instalación
- Paro `dnsmasq` en `cortafuegix` (nota: la casa se queda sin DNS/DHCP)
- Reactivo `systemd-resolved` para que haga bind al puerto 53.
- Instalo Pi-Hole 6
- Configuro Pi-Hole 6 y adapto para usar los ficheros antiguos de `dnsmasq`.
- Vuelvo a cambiar Netplan para que apunte a si mismo y reactivo `systemd-resolved`.
- Desinstalo dnsmasq
- Paro la máquina virtual Pi-Hole 5 antigua

### Salvo la configuración

Guardo los ficheros importantes de `dnsmasq` para su uso posterior. Me guardo mis tres ficheros que tengo bajo `/etc/dnsmasq.d` al home de mi usuario.

```shell
ls -al /home/luis/*.conf
-rw-r--r-- 1 root root  3620 mar  9 09:30 /home/luis/000-dnsmasq.conf
-rw-r--r-- 1 root root 15609 mar  9 09:30 /home/luis/100-vlan.conf
-rw-r--r-- 1 root root  3671 mar  9 09:30 /home/luis/205-vlan.conf
```

### Copia de serguridad

En mi caso hago un clone del router `cortafuegix`. Es una máquina virtual en mi servidor Proxmox.

### Netplan

Cambio `netplan` para que `cortafuegix` resuelva todo vía la `192.168.100.224` (Pi-Hole 5 antiguo) mientras dura la migración.

```shell
# e /etc/netplan/netplan.yaml
:
      # Vlan principal
      vlan100:
        :
        nameservers:
          addresses:
          - 192.168.100.224  <-- IP del pihole externo, antes tenía 127.0.0.1
:
# netplan apply
# resolvectl
:
Link 6 (vlan100)
Current Scopes: DNS
     Protocols: +DefaultRoute +LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
   DNS Servers: 192.168.100.224
    DNS Domain: parchis.org
```

# Paro dnsmasq

Pi-hole utiliza su propia versión de dnsmasq integrada en FTL (un fork de dnsmasq optimizado). Para evitar conflictos para la que tengo instalada en Ubuntu. Que, por cierto, luego desinstalaré.

```shell
# systemctl stop dnsmasq
# systemctl disable dnsmasq
```

### Reactivo systemd-resolved

Para que haga bind al puerto 53, lo dejo "de fábrica". Lo había quitado porque cuando tienes dnsmasq y sirves DNS no hace falta.

```shell
# e /etc/systemd/resolved.conf
[Resolve]
#DNSStubListener=yes   <== Antes lo tenia descomentado y con valor "no"

# systemctl restart systemd-resolved
# netstat -tulpn |grep 53
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      86520/systemd-resol
udp        0      0 127.0.0.53:53           0.0.0.0:*                           86520/systemd-resol
udp        0      0 0.0.0.0:161             0.0.0.0:*                           1253/snmpd
# resolvectl
Global
         Protocols: -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
  resolv.conf mode: foreign
Current DNS Server: 192.168.100.1
       DNS Servers: 192.168.100.1
        DNS Domain: parchis.org
:
Link 6 (vlan100)
Current Scopes: DNS
     Protocols: +DefaultRoute +LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
   DNS Servers: 192.168.100.224
    DNS Domain: parchis.org
```

El estado actual es:

- `cortafuegix` puede resolver vía el `pihole` que tengo activo (`.224`) y llega a internet sin problemas.
- El resto de la casa está ciega (no hay DNS ni DHCP server)

### Instalación

Descargo e instalo Pi-hole 6 con:

```shell
curl -sSL https://install.pi-hole.net | bash
```

Sigo el proceso estándar de instalación. Una vez termina me ofrece conectar con la pantalla de administración en la ip de mi equipo `http://192.168.100.1/admin` con contraseña por defecto que me muestra al terminar la instalación y que cambio nada más entrar.

### Configuración

La configuración de Pi-Hole 6 se ha cambiado de sitio, ahora queda todo en un único fichero `/etc/pihole/pihole.toml`. Se "debe" configurar todo desde el interfaz web, aunque si quieres editarlo no te olvides de parar el servicio con `systemctl stop pihole-FTL.service`.

- Dejo aquí una copia de mi fichero [/etc/pihole/pihole.toml](https://gist.github.com/LuisPalacios/4d3893f370ec1784aedc292519f09745)
- `/etc/pihole/dnsmasq.conf` se crea automáticamente desde el anterior, no hace falta editarlo.

He configurado Pi-Hole para que use un fichero externo donde tengo mi configuración de estáticas DHCP. El primero es el fichero `/etc/dnsmasq.d/100-vlan.conf`, dejo aquí algunas entradas a modo de ejemplo:

```shell
$ cat /etc/dnsmasq.d/100-vlan.conf
:
#### Ejemplo para Access Points
#### Nota: como TAG se puede usar cualquier cosa, aquí uso "capwap"
dhcp-option=set:capwap,option:router,192.168.100.1
dhcp-option=set:capwap,option:dns-server,192.168.100.1
dhcp-option=set:capwap,option:netmask,255.255.252.0
dhcp-option=set:capwap,43,192.168.252.238
dhcp-host=set:capwap,12:34:56:78:16:10,ap-paso.parchis.org,192.168.100.220
dhcp-host=set:capwap,12:34:56:78:57:48,ap-buhardilla.parchis.org,192.168.100.221
dhcp-host=set:capwap,12:34:56:78:35:F8,ap-cuartos.parchis.org,192.168.100.222

#### Ejemplo de asignaciones estáticas
dhcp-host=set:vlan100,12:34:56:77:0E:A1,192.168.100.2,panoramix.parchis.org
dhcp-host=set:vlan100,12:34:56:70:49:ED,192.168.100.3,idefix.parchis.org
dhcp-host=set:vlan100,12:34:56:75:0d:20,192.168.100.4,idefix-wifi.parchis.org
dhcp-host=set:vlan100,12:34:56:75:df:41,192.168.100.5,kymera.parchis.org
:
```

### Cambio netplan y desactivo `systemd-resolved`

Ya no lo necesito, así que lo cambio para que no haga un bind al puerto 53. En principio no hace falta (porque escucha en `127.0.0.53`), pero así evito que cuando `cortafuegix` necesite resolver haga consultas dobles a `127.0.0.53:53` y `127.0.0.1:53`.

```shell
# cat /etc/systemd/resolved.conf
[Resolve]
DNSStubListener=no

# systemctl restart systemd-resolved
```

Dejo `netplan` para que `cortafuegix` se haga consultas a si mismo

```shell
# e /etc/netplan/netplan.yaml
:
      # Vlan principal
      vlan100:
        :
        nameservers:
          addresses:
          - 127.0.0.1
:
# netplan apply
```

### Terminar la migración

Una vez que está todo configurado y arrancado, observo que está escuchando en los puertos adecuados y bien configurado:

```shell
# resolvectl
Global
         Protocols: -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
  resolv.conf mode: foreign
Current DNS Server: 192.168.100.1
       DNS Servers: 192.168.100.1 127.0.0.1
        DNS Domain: parchis.org
:
Link 5 (vlan100)
Current Scopes: DNS
     Protocols: +DefaultRoute +LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
   DNS Servers: 127.0.0.1
    DNS Domain: parchis.org

# netstat -tulpn |grep 53
tcp        0      0 0.0.0.0:53              0.0.0.0:*               LISTEN      2128/pihole-FTL
tcp6       0      0 :::53                   :::*                    LISTEN      2128/pihole-FTL
udp        0      0 0.0.0.0:53              0.0.0.0:*                           2128/pihole-FTL
udp6       0      0 :::53                   :::*                                2128/pihole-FTL
```

Las consultas propias se las va a hacer a si mismo, y cualquier otra la derivará a su forwarder.

```shell
# nslookup ibm.com
Server:         192.168.100.1
Address:        192.168.100.1#53

Non-authoritative answer:
Name:   ibm.com
Address: 104.85.45.187
Name:   ibm.com
Address: 2a02:26f0:b80:693::3831
:
```

Compruebo desde un ordenador de la red que la resolución DNS e inversa son correctas. Como puedes observar no necesito añadir el nombre del dominio, que se autocompleta solo. Comprobado con clientes Windows, Mac, Linux y dispositivos móviles.

```PowerShell
luis@kymeraw:~ ❯ nslookup.exe panoramix.parchis.org
Server:  pi.hole
Address:  192.168.100.1

Name:    panoramix.parchis.org
Address:  192.168.100.2

luis@kymeraw:~ ❯ nslookup.exe 192.168.100.2
Server:  pi.hole
Address:  192.168.100.1

Name:    panoramix.parchis.org
Address:  192.168.100.2

```

### Desinstalo dnsmasq

Una vez que tengo Pi-Hole haciendo DNS/DHCP ya no necesito el paquete `dnsmasq` de Ubuntu. Ademas elimino una versión personalizada que creé para systemd.

```shell
# apt remove dnsmasq-logrotate dnsmasq
# apt autoremove -y --purge
# rm /etc/systemd/system/dnsmasq.service
```

### Prueba de concepto

Muy importante, una vez que que todo está funcionando, voy a parar la máquina virtual con el PiHole 5 antiguo y rearrancar el router. No quiero tener sorpresas si ocurre un reboot y no me va DNS/DHCP, que suele significar caos 😂

```shell
# reboot -f
```

Compruebo que funciona todo y ademas puedo acceder a la consola de administración en [http://192.168.100.1/admin](http://192.168.100.1/admin)

<div class="image-box">
  <img src="/img/posts/2025-03-08-router-pihole-02.png" alt="Consola de administración" width="700px" />
  <div class="image-caption">Consola de administración</div>
</div>

### Listras blancas y negras

He configurado PiHole para que se suscriba 5 listas negras y 1 lista blanca. La suscripción la actualiza cada semana y en mi caso supone una base de datos de más de 350.000 entradas.

Para entender esto de las listas, dejo algunos enlaces a proyectos interesantes

- [StevenBlack](https://github.com/StevenBlack/hosts) - Consolida direcciones de hosts de varias fuentes bien conservadas
- [FadeMind extrahosts](https://github.com/FadeMind/hosts.extras) - Reglas extra para el proyecto de hosts de StevenBlack
- [FadeMind whitelists](https://github.com/FadeMind/hosts.whitelists) - Coleciones de whitelists.
- [Adfilt](https://github.com/DandelionSprout/adfilt) - Listas de filtros web para innumerables temas diferentes
- [oisd](https://oisd.nl/) - Bloquea dominios no deseados o dañinos. Reduce los anuncios, disminuye el riesgo de malware y mejora la privacidad.
- [oisd big](https://big.oisd.nl) - Bloquea anuncios, anuncios de aplicaciones (móviles), phishing, malvertising, malware, spyware, ransomware, cryptojacking, ... Telemetría/Analítica/Seguimiento (Cuando no sea necesario para el correcto funcionamiento)
- [oisd small](https://small.oisd.nl) - Se centra principalmente en bloquear anuncios

#### Blocklists

- Entro en `Lists > Subscribed lists` y añado las siguientes listas negras como **Blocklist**

```txt
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
https://raw.githubusercontent.com/FiltersHeroes/KADhosts/master/KADhosts.txt
https://big.oisd.nl
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts
https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareAdGuardHome.txt
```

#### Allowlists (Whitelists)

- Entro en `Lists > Subscribed lists` y añado las siguientes lista blanca como **Allowlists**. Se trata de mi propia lista de sitios permitidos, que he ido sacando desde diferentes fuentes y me permite una navegación sin demasiados problemas.

- [Whitelist compatible con PiHole 6](https://gist.githubusercontent.com/LuisPalacios/2c34004dbe400bc68148fa35ba873cc7/raw/whitelist_pihole6.txt)

<div class="image-box">
  <img src="/img/posts/2025-03-08-router-pihole-03.png" alt="Gestión de la suscripción a listas" width="700px" />
  <div class="image-caption">Gestión de la suscripción a listas</div>
</div>
