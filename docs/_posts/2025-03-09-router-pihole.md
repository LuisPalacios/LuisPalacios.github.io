---
title: "Router con PiHole 6"
date: "2025-03-09"
categories: administración
tags: domótica networking avanzado linux pve proxmox ubuntu dhcp dns dnsmasq pihole
excerpt_separator: <!--more-->
---

![Logo Pihole Router](/assets/img/posts/logo-piholednsmasq.svg){: width="150px" style="float:left; padding-right:25px" }

Hace un par de meses moví el servicio DHCP y DNS a mi Router linux de casa y dejé el servicio de Pi-Hole 5 en otra máquina virtual. A pesar de funcionar perfecto me topé con una pega, el troubleshooting desde PiHole es complicado, porque todas las peticiones DNS las resuelve el router y en PiHole no se ve nada, así que he decidido volver a cambiar el diseño.

En este apunte describo cómo instalo Pi-Hole 6 en mi router Linux para que ofrezca DNS, DHCP (con dnsmasq) y sumidero de la publicidad. Esto conlleva deshacer la instalación nativa de dnsmasq.

<br clear="left"/>
<!--more-->

## Introducción

En mi "montaje" anterior tenía el [Servidor DHCP y DNS]({% post_url 2024-12-26-dnsmasq %}) con dnsmasq en mi router y un Pi-Hole 5 en una máquina virtual como sumidero de la publicidad. En este apunte evoluciono a un montaje distinto, **instalo Pi-Hole 6 en el router, sustituyendo el dnsmasq y evoluciono toda la configuración anterior**, de modo que a partir de ahora Pi-Hole 6 hace todo: DNS, DHCP y sumidero de publicidad:

{% include showImagen.html
      src="/assets/img/posts/2025-03-09-router-pihole-01.svg"
      caption="Router con PiHole"
      width="400px"
      %}

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

```bash
ls -al /home/luis/*.conf
-rw-r--r-- 1 root root  3620 mar  9 09:30 /home/luis/000-dnsmasq.conf
-rw-r--r-- 1 root root 15609 mar  9 09:30 /home/luis/100-vlan.conf
-rw-r--r-- 1 root root  3671 mar  9 09:30 /home/luis/205-vlan.conf
```

### Copia de serguridad

En mi caso hago un clone del router `cortafuegix`. Es una máquina virtual en mi servidor Proxmox.

### Netplan

Cambio `netplan` para que `cortafuegix` resuelva todo vía la `192.168.100.224` (Pi-Hole 5 antiguo) mientras dura la migración.

```bash
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

```bash
# systemctl stop dnsmasq
# systemctl disable dnsmasq
```

### Reactivo systemd-resolved

Para que haga bind al puerto 53, lo dejo "de fábrica". Lo había quitado porque cuando tienes dnsmasq y sirves DNS no hace falta.

```bash
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

```bash
curl -sSL https://install.pi-hole.net | bash
```

Sigo el proceso estándar de instalación. Una vez termina me ofrece conectar con la pantalla de administración en la ip de mi equipo `http://192.168.100.1/admin` con contraseña por defecto que me muestra al terminar la instalación y que cambio nada más entrar.

### Configuración

La configuración de Pi-Hole 6 se ha cambiado de sitio, ahora queda todo en un único fichero `/etc/pihole/pihole.toml`. Se "debe" configurar todo desde el interfaz web, aunque si quieres editarlo no te olvides de parar el servicio con `systemctl stop pihole-FTL.service`.

- Dejo aquí una copia de mi fichero [/etc/pihole/pihole.toml](https://gist.github.com/LuisPalacios/4d3893f370ec1784aedc292519f09745)
- `/etc/pihole/dnsmasq.conf` se crea automáticamente desde el anterior, no hace falta editarlo.

He configurado Pi-Hole para que use un fichero externo donde tengo mi configuración de estáticas DHCP. El primero es el fichero `/etc/dnsmasq.d/100-vlan.conf`, dejo aquí algunas entradas a modo de ejemplo:

```bash
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

```bash
# cat /etc/systemd/resolved.conf
[Resolve]
DNSStubListener=no

# systemctl restart systemd-resolved
```

Dejo `netplan` para que `cortafuegix` se haga consultas a si mismo

```bash
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

```bash
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

```bash
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

```PS1
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

```bash
# apt remove dnsmasq-logrotate dnsmasq
# apt autoremove -y --purge
# rm /etc/systemd/system/dnsmasq.service
```

### Prueba de concepto

Muy importante, una vez que que todo está funcionando, voy a parar la máquina virtual con el PiHole 5 antiguo y rearrancar el router. No quiero tener sorpresas si ocurre un reboot y no me va DNS/DHCP, que suele significar caos 😂

```bash
# reboot -f
```

Compruebo que funciona todo y ademas puedo acceder a la consola de administración en [http://192.168.100.1/admin](http://192.168.100.1/admin)

{% include showImagen.html
      src="/assets/img/posts/2025-03-09-router-pihole-02.png"
      caption="Consola de administración"
      width="700px"
      %}
