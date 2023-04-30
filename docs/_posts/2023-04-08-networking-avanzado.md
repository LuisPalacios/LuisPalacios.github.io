---
title: "Domótica y Networking"
date: "2023-04-08"
categories: administración
tags: domótica networking avanzado linux pve proxmox kvm qemu cloud-init alpine debian ubuntu plantilla virtualización
excerpt_separator: <!--more-->
---


![logo linux router](/assets/img/posts/logo-homenet.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Comparto mi **networking doméstico avanzado**, resiliente, funcional y con una buena experiencia de usuario, incluso tengo la opción de *llamar a la puerta* desde Internet para accesos puntuales. No queda más remedio, las redes caseras de hoy en día acaban soportando múltiples servicios y con la irrupción de la domótica se múltiplican.  

Este apunte no trata sobre la domótica, pero sí que he visto que  ha hecho crecer exponencialmente el número de dispositivos y mantener la red de un hogar inteligente y automatizado es importante. Este apunte está dedicado a esos *Geeks* y *Techys* que, como yo, llevamos ya tiempo metidos en la *complicación del networking en una red casera domotizada*.


<br clear="left"/>
<!--more-->
 
 
## Punto de partida

¿A que me refiero con **networking avanzado**?. Pues que soporte de forma resiliente y segura *muchos cacharros variopintos*, vía LAN/WiFi y puntualmente desde internet. Que pueda usar certificados para trabajar con `https`, que pueda entrar a ciertos servicios *bajo demanda* desde intenet y ya por pedir, que siga funcionando si cae internet o la WiFi (por lo menos la mayoría de las cosas).

¿Cuanto puede crecer tu red? pues si sumamos switches, AP's, servidores físicos, virtuales, sensores, relés, actuadores, etc. yo veía el otro día 122 IP's únicas 😱.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-01.png"
    caption="En mi red hay, al menos, 122 equipos que hablan IP"
    width="400px"
    %}


<br/>

----

<br/>

### Internet

Empiezo la casa por el tejado, es fundamental decidir cómo conectar y controlar lo que entra y sale: 

- Qué uso como **router/firewall** para entrar/salir a Internet. 
- Cómo montar el **dominio dinámico**, para llamar con nombre desde Internet.
- Cómo activar un servicio de **llamar a la puerta** para abrir puertos bajo demanda.
- Algunos servicios a los que conectar desde internet, como **ssh, OpenVPN**.

Probablemente el **99% de los hogares usa el router del Proveedor de Servicios (Operadora) y cuelga todo debajo**, traen varios puertos y un punto de acceso embebido, suena bien. 

Hasta que necesitas algo más, en ese caso mi **recomendación es poner detrás mi propio router + switch(es) + AP(s)** y desactivar el WiFi del Proveedor 😆. Partiendo de esta premisa, tenemos tres opciones (ojo!, he documentado usando los nombres y opciones validos para mi proveedor (movistar), si tienes otro podría haber ligeros cambios):

<br/>

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-02.svg"
    caption="Arquitectura funcional: para un control total mejor poner mi router"
    width="800px"
    %} 

<br/>

- **Estándar**: Conecto mi Router al del Proveedor y recibo IP privada (`192.168.100.0/24`).
  - Desventajas menores: Hay que hacer dos veces Port Forwarding y NAT.
  - Desventajas mayores: Pierdes el control de VoIP y de IPTV (si lo tienes contratado).
  - Ventajas: No tocas el servicio del Proveedor, suele ser muy estable. El soporte funciona y no hay que dar explicaciones. 
- **Modo Bridge**: Configuro el Router en modo Bridge, yo no lo he configurado nunca. Hay routers (p.ej GPT-2841GX4X5) que no lo soportan. Sus ventajas y desventajas son las mismas que el punto siguiente (ONT), en teoría recibes todas las VLAN's. 
- **ONT**: Conecto mi Router al *Optical Network Termination*, a su puerto ETH1, y me presenta: VLAN-6 para "datos", VLAN-2 para IPTV y VLAN-3 para VoIP.
  - Desventajas: Te sales del estándar y no es nada recomendable si no tienes experiencia en routing/switching. 
  - Ventajas: Todos los beneficios de tener mi propio router en medio, además el control total del tráfico IPTV y VoIP, además me ahorro el doble port-forwaring y doble NAT. 

Si no queires controlar el tráfico IPTV/VoIP te recomiendo la opción Estándar (izquierda), es perféctamente válidad para todo lo que explico en este apunte. Tendrás que hacer port forwarding "también" en el Router del Proveedor y para que **Llamar a la puerta** funcione tendrás que abrir un rango de puertos. El apunte se centra en mi caso, la opción ONT.

<br/> 

#### Mi router

Uso **Linux** sobre máquina virtual, su **routing nativo con `iptables`** para la parte de firewall. Conmuta el tráfico entre internet (`pppoe (vlan6)`) y mi intranet (`vlan 100`). Por defecto **deniego todo el tráfico de entrada** y hago **Masquerade en salida**. Exactamente igual que el router de movistar. Como novedad, actualizo mi dominio DNS público con la nueva IP pública dinámica que recibo (p.ej: `ssh.tudominio.com`).

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-03.svg"
    caption="La seguridad es completa, por defecto no entra nada"
    width="800px"
    %} 

| ¿Qué ventajas tiene ponerlo si hace lo mismo?. Bueno, pues que puedo **hacer algunas cosas adicionales, con un control total**: sistema para llamar a la puerta y abrir puertos bajo demanda, OpenVPN con control, silencio a los pings (si conectas directamente al ONT), identificar intentos de ataques, control del tráfico VoIP e IPTV. |

En vez de un Linux a pelo, hay más opciones, la primera sería montar distribuciones como [OpenWrt](https://openwrt.org), [IPFire](https://www.ipfire.org) o [pfSense](https://www.pfsense.org) (solo intel), otra es irse a hardware dedicado estilo Mikrotik u otros y la última, muy barata, usar una Raspberry Pi 4B de 1GB con Raspberry Pi OS 64bits, su routing nativo + `iptables` o instalarle una imagen de [OpenWrt](https://openwrt.org) o [IPFire](https://www.ipfire.org). 

En cualquier caso siempre hará falta un Switch (mínimo iría a uno de 8xGbe con soporte de VLAN's e IGMP) y uno o más AP's que soporten Roaming para la WiFi.

Volviendo a mi instalación, un Linux a pelo en máquina virtual en un host ([Proxmox VE](https://www.proxmox.com/en/proxmox-ve)) sobre NUC de Intel. En realidad hace poco lo convertí en un Cluster Proxmox formado por 2xNUC's + una Pi3B para tener mejor tolerancia a fallos de mis servicios caseros. 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-04.svg"
    caption="Representacion física de conexión"
    width="450px"
    %} 

Utilizo **[Ubuntu 22.04 LTS](https://ubuntu.com/blog/tag/LTS)**, robusto y fácil de mantener. La versión `LTS` es una versión de soporte a largo plazo que recibe actualizaciones de seguridad y corrección de errores durante cinco años, especialmente adecuado cuando se necesita **estabilidad**. Instalé la VM usando una [Plantilla de VM en Proxmox]({% post_url 2023-04-07-proxmox-plantilla-vm %}).

| Importante con proxmox: al conectar el Host (o los hosts) al puerto Trunk de tu Switch, yo he utilizado OVS Bridge (en vez de linux bridge). Da igual, ambos ofrecen lo mismo, pero OVS es muy útil si en el futuro haces laboratorios con VM's que lo necesiten. |

Una vez que arranqué mi VM desde la plantilla, instalé algunas herramientas, elimino `cloud-init` y preparo el ficheor `netplan` (para el modo trunk).

```console
root@muro:~# apt install qemu-guest-agent
root@muro:~# apt install nano net-tools iputils-ping tcpdump
```

Elimino cloud-init

```console
root@muro:~# rm -fr /etc/cloud
root@muro:~# apt purge -y cloud-init
root@muro:~# rm /etc/netplan/50-cloud-init.yaml
```

Netplan para la configuración de red. 

```console

root@muro:~# cat /etc/netplan/50-muro.yaml
# Fichero netplan para muro
network:
  ethernets:
      eth0:
        dhcp4: no
  vlans:
      vlan6:                             <== VLAN con el ONT (aquí irá el ppp)
        id: 6
        link: eth0
        macaddress: "52:54:12:34:56:78"
        dhcp4: no
      vlan100:                           <== VLAN principal
        id: 100
        link: eth0
        macaddress: "52:54:12:12:12:12"  <== Debe coincidir con el siguiente paso
        addresses:
        - 192.168.100.1/22                 <== Mi IP en la intranet
        nameservers:
          addresses:
          - 192.168.100.224                <== El DNS/DHCP server
          search:
          - tudominio.com
      vlan33:                            <== Un ejemplo de VLAN extra
        id: 33
        link: eth0
        macaddress: "52:54:AB:CD:EF:33"
        addresses:
        - 192.168.33.1/24
  version: 2
```

Desde Proxmox: `muro -> hardware -> network device` configuro la tarjeta de red de la máquina virtual, le pongo la misma MAC que he configurado en el fichero `netplan` (`52:54:12:12:12:12`).

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-05.png"
    caption="Configuro la tarjeta para que reciba el TRUNK"
    width="600px"
    %} 

Para que el router `muro` reciba el Trunk basta con dejar vacío el campo `VLAN Tag`. También **recomiendo quitar la opción `Firewall` en las opciones** (aunque lo tengas desactivado a nivel global en Proxmox). A mi me dió problemas el `IGMP` mullticast.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-06.svg"
    caption="El Router software se encarga de conmutar de forma segura"
    width="600px"
    %} 

Este equipo actúa como router entre las diferentes interfaces y redes disponibles, así que es importante configurar `PPP`, `NAT` e `iptables`. Aquí tienes los servicios y Scripts que utilizo.

Son ficheros de referencia, así que recomiendo **revisarlos para adaptarlos a tu instalación**. 
  
- [/etc/systemd/system/internet_wait.service](https://gist.github.com/LuisPalacios/68fccb64e9e1b8ef598ee7bf6de181ee)
- [/etc/systemd/system/firewall_1_pre_network.service](https://gist.github.com/LuisPalacios/d90ff449e2e9886341ffa019008757b4)
- [/etc/systemd/system/firewall_2_post_network.service](https://gist.github.com/LuisPalacios/3345a1ad94231a74fe5442c738e97cb0)
- [/etc/default/netSetupVars](https://gist.github.com/LuisPalacios/bcc7df9cd60937f6cec40a6c9ede6469)
- [/root/firewall/firewall_clean.sh](https://gist.github.com/LuisPalacios/dfc8a5e82b3dab4e2ef78ccf77263a9a)
- [/root/firewall/firewall_1_pre_network.sh](https://gist.github.com/LuisPalacios/b648ef38206caa8c28cbc148a89ff364)
- [/root/firewall/firewall_2_post_network.sh](https://gist.github.com/LuisPalacios/c7ed6d89343e9238770db550b5dc6718)
- [/root/firewall/firewall_verifica.sh](https://gist.github.com/LuisPalacios/252db87b4e9866e2132e8bf8d71571cb)
- [/etc/ppp/pap-secrets](https://gist.github.com/LuisPalacios/3b4b33fd4378663cc38c09065b5e3b3f)
- [/etc/ppp/options](https://gist.github.com/LuisPalacios/96e392282fd9011986614c2a32fa3273)
- [/etc/ppp/peers/movistar](https://gist.github.com/LuisPalacios/07e99b6067fba47886c0a79c5bab26b7)
- [/etc/systemd/system/ppp_wait@.service](https://gist.github.com/LuisPalacios/647dc4190a3c9f80efe7188ac955cf87)
- [/etc/systemd/system/ppp_nowait@.service](https://gist.github.com/LuisPalacios/e216877fe5595d7b2bdcbc70257e7166)


Recuerda habilitarlos. He dejado dos ejemplos de Unidades Systemd para el arranque de la sesión `PPPoE`, una que espera a que se establezca la sesión y otra que no espera. En mi caso uso la primera.

```console
# chmod 755 /root/firewall/*.sh
# systemctl enable internet_wait.service
# systemctl enable firewall_1_pre_network.service
# systemctl enable firewall_2_post_network.service
# systemctl enable ppp_wait@movistar.service
```

<br/> 

#### Dominio dinámico

Un dominio dinámico es un servicio que permite asignar un nombre (subdominio) a mi dirección IP pública, la cual puede cambiar periódicamente. Especialmente útil para saber a dónde llamar cuando quiera acceder desde Internet a mis servicios, por ejemplo **Home Assistant, ssh, acceso OpenVPN**.

Asumiendo que eres propietario de un dominio de internet, por ejemplo `tudominio.com`, tendrás que trabajar con un proveedor de servicios de dominio **dinámico** como DynDNS, No-IP, DuckDNS, etc. Probablemente tu proveedor de DNS también lo soporte, como es mi caso. 

Yo trabajo con `cdmon.es` y entre sus páginas se encuentra la [documentación para actualizar la IP](https://ticket.cdmon.com/es/support/solutions/articles/7000005922-api-de-actualización-de-ip-del-dns-gratis-dinámico/). Dejo un ejemplo sobre cómo lo hago, con un servicio en `systemd` y un pequeño `script`. 

- [/etc/systemd/system/cdmon_update.service](https://gist.github.com/LuisPalacios/0455cff3e67d500772c23b58b2a8ff10)
- [/etc/systemd/system/cdmon_update.timer](https://gist.github.com/LuisPalacios/415e188233fa71e3651413580281839a)
- [/usr/bin/cdmon_update.sh](https://gist.github.com/LuisPalacios/a3ce16ea1ad60064849cd08c11b284e0)

```console
# chmod 755 /usr/bin/cdmon_update.sh
# systemctl enable cdmon_update.timer
```

El dominio que tengo en internet (ej.: `tudominio.com`) está siendo servido por mi proveedor de DNS y tengo dados de alta varios registros de tipo `'A'` resolviendo a la misma IP Pública de mi casa: Home Assistant -> `ha.tudominio.com`, SSH -> `ssh.tudominio.com`, OpenVPN -> `vpn.tudominio.com`.  

Cuando estoy "dentro" (en la Intranet), cuento con un servidor DNS interno que sirve exactamente el mismo dominio (`tudominio.com`) entregando en esta ocasión IP's privadas de casa. De esta forma, este dondes esté (internet o intranet) se resuelve correctamente, bien con una IP pública (cuando se consulta a mi proveedor dns) o una privada (cuando se consulta a mi servidor DNS interno, más adelante vemos que lo hago con PiHole). 

De momento muestro cómo está configurada la parte de Internet: 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-07.svg"
    caption="Cómo hago la resolución de nombres"
    width="800px"
    %} 

<br/>

#### Llamar a la puerta

El **Port Knocking** es una técnica que consiste en enviar varios paquetes al Router/Firewall para que reconozca que estás "llamando a la puerta" y la abra temporalmente (solo a la IP desde la que llamo)

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-08.jpg"
    caption="Aplicaciones involucradas"
    width="300px"
    %} 
    
Uso **PortKnock** (App para smartphone): lanza la petición (1) Ábreme el puerto para llegar a Home Assistant (que envía una serie de paquetes con una cadencia determinada), el router/firewall se da por enterado y abre durante un rato el puerto `28123` (2) para que **Home asistant** pueda entrar. 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-09.svg"
    caption="Así funciona *Llamar a la puerta*"
    width="800px"
    %} 

En este ejemplo tengo configurado el App HomeAssistant en el móvil para que siempre conecte con `ha.tudominio.com:28123`, de modo que da igual que esté en internet o en casa, se resolverá la IP correcta en cada momento.

Podemos configurar cuantos toques se dan a la puerta y a qué número de puertos. Deben coincidir en el servidor y cliente. Por ejemplo, dar tres toques cada segundo sería: Envía un `SYN` al puerto #1, espera un segundo, un `SYN` al puerto #2, espera otro segundo y envía un último `SYN` al puerto #3. En ese instante nuestro daemon `knockd` ejecuta lo que queramos, que será típicamente `iptables` para abrir el puerto (`28123` en este ejemplo).

**Instalación**
  
```console
root@muro:~# apt install knockd
```

Aquí tienes un ejemplo del fichero de configuración, obviamente con números inventados. Cámbia los puertos de llamada, los puertos de tu servidor, la cadencia, etc. Así tendrás una configuraicón prácticamente imposible de descubrir. 

Dejo un fichero de configuración de referencia, recomiendo **revisarlo para adaptarlo a tu instalación**. 

- [/etc/knockd.conf](https://gist.github.com/LuisPalacios/6132bb17999934f5eb51cf186d94910f)

Podrías complicarlo más aún. Imagina un proceso que cada semana te cambia los puertos, tanto en el cliente como en el servidor, de forma aleatoria. Ahí sí que se lo has puesto difícil a cualquiera que intente averiguar cuando y por dónde abres en tu firewall.

**Activación del servicio**

```console
root@muro:~# systemctl enable knockd
```

<br/>

#### OpenVPN

Como VPN Server utilizo [OpenVPN](https://openvpn.net/) que sigue siendo la mejor solución de Servidor de Acceso seguro a los servicios internos de mi red casera desde internet. Es fiable, rápido y muy seguro. Como contrapartida, su configuración es más compleja y tiene el inconveniente de necesitar un software adicional en los clientes.

Como cliente utilizo [Passepartout](https://passepartoutvpn.app/). Para poder entrar en casa necesito abrir un puerto (típicamente en UDP) y hay dos formas de hacerlo. 

* **Dejar siempre un puerto abierto**, aunque OpenVPN es seguro prefiero no hacerlo. Si quieres implementaro, esto es lo que iría en el fichero [firewall_1_pre_network.sh](https://gist.github.com/LuisPalacios/b648ef38206caa8c28cbc148a89ff364).

```bash
## ACCESO EXTERNO a mis Servicios
## IPSec como Servidor:  XXXXXX (Cambiar por el puerto donde escuchas en ipsec)
#  Dejé de usar esta opción para pasar a usar knockd.
#iptables -N CH_OPENPORTS
#iptables -A INPUT -p udp -m udp  -m multiport  --dports XXXXXX -m conntrack --ctstate NEW  -j CH_OPENPORTS  # OpenVPN en UDP
#if [ "${LOGSERVICIOS}" = "yes" ] || [ "${LOGALL}" = "yes" ]; then
#   iptables -A CH_OPENPORTS -j $LOGGING "CH_OPENPORTS -- OK "
#fi
#iptables -A CH_OPENPORTS -j ACCEPT
```

* **Abrir un puerto bajo demanda con el método de Llamar a la puerta**. Esta es mi opción preferida. Tal como describí con el ejemplo con Home Assistant, hago lo mismo para entrar por IPSec; llamo a la puerta ([/etc/knockd.conf](https://gist.github.com/LuisPalacios/6132bb17999934f5eb51cf186d94910f)), se abre contra el OpenVPN y arranco mi cliente.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-10.svg"
    caption="Uso knockd para abrir el puerto del servidor OpenVPN"
    width="500px"
    %} 

No documento la instalación, solo te dejo un ejemplo de configuración a modo de referencia, recomiendo **revisarlo para adaptarlo a tu instalación**. 

- [/etc/openvpn/server/muro_access_server.conf](https://gist.github.com/LuisPalacios/c60fc46dfc2867aa716820b63cd30b2e)

Para instalarlo y configurarlo hay mucha literatura al respecto, yo tengo un par de apuntes (algo antiguos pero válidos) que puedes usar como referencia: 

- [Bridge Ethernet]({% post_url 2014-10-19-bridge-ethernet %}) sobre cómo extender la red de mi casa a un sitio remoto a través de internet, donde instalo y configuro OpenVPN
- [OpenVPN Server]({% post_url 2014-09-14-vpn-server-en-linux %}) donde describo describir cómo montar un servidor VPN casero sobre linux Gentoo. 

<br/>

----

<br/>

### Intranet

Vamos bajando por la casa, estos son los servicios que tengo activos: 

- Servicios de Networking: Además de lo que hemos visto en la sección anterior tengo un par de Switches y un par de Access Points. Un Servidor DNS/DHCP sobre PiHole, un controlador para los AP's, un Proxy Inverso y algunas herramientas (opcionales) de monitorización (como Gatus, Uptime Kuma, LibreNMS, Netdisco). 

- Servicios de domótica: El networking de la casa está soportando Home Assistant, Node-RED, Zigbee2MQTT, Mosquito, Grafana e InfluxDB. Permiten controlar y automatizar diferentes dispositivos en el hogar, como la iluminación, los sistemas de climatización, sensores, luces, enchufes, relés, las cerraduras y los electrodomésticos. La gran mayoría utilizan WiFi y algunos Zigbee (que no es objeto de este apunte).

- Servicios adicionales: Además tengo un QNAP para hacer backups y un servidor GIT que permite alojar y compartir proyectos de software y configuraciones. Como no, también monto de vez  en cuando laboratorios... 

Recomiendo, aunque parezca obvio decirlo, montar todo con Switches con puertos a 1Gbps y equipos (AP's) WiFi que soporten la mayor velocidad que podáis. Hoy en día con la posibilida de fibra y 1Gbps con Internet es la mínima velocidad que tenemos que soportar en casa.

<br/>


#### Hardware para VM

Tengo varios servicios los monto sobre el mismo Hardware usando virtualización. Utilizo una mezcla de máquinas virtuales y/o contenedores (Docker o LXC). Usé durante años un Host Linux con KVM/QEMU. Hace poco cambié a [Proxmox VE](https://www.proxmox.com/en/proxmox-ve). 

Poner todo los huevos en el mismo cesto no es aconsejable y los Tecky's lo sabemos bien. De hecho, cuando se me caía el "host" con mis VM's me quedaba sin casa 😂 y me caía la bronca. Hace poco me metí en la aventura de crear un Cluster Proxmox VE con 2xNUC's + 1xPi3B para hospedar las máquinas virtuales, contenedores LXC o Docker con servicios. La Pi es lo más barato que tenía para que el Cluster "negocie bien" la tolerancia a fallos, no tiene servicios.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-11.jpg"
    caption="Como decía, llevo tiempo complicando mi instalación"
    width="600px"
    %} 

<br/>

#### DNS y DHCP

Como servidor DNS y DHCP soy muy fan de [Pi-hole](https://pi-hole.net). Además de DNS/DHCP hace de sumidero de la publicidad no deseada. Tengo un apunte dedicado a cómo instalar un [Pi-hole casero]({% post_url 2021-06-20-pihole-casero %}).

Mantengo en un excel la lista de equipos, MACs y la IP que les asigno, una CMDB muy casera y así tengo al día el par de ficheros donde se guardan las asignaciones para el DHCP y los nombres DNS.

En internet mi dominio `tudominio.com` está siendo servido por mi proveedor de DNS. En la Intranet mi `tudominio.com` está siendo servidor por PiHole.

Amplío lo que mostré antes, con el añadido de PiHole para el servicio DNS (y DHCP) interno.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-12.svg"
    caption="Cómo hago la resolución de nombres"
    width="800px"
    %}

Cuando alguien de la Intranet pide un nombre lo hace a PiHole. Si es una consulta a `tudominio.com` entregará la IP privada. Si la consulta es para cualquier dominio de internet entonces se irá a los Servidores ROOT o al intermediario que haya configurado (por ejemplo los DNS Servers de Movistar o el de google `8.8.8.8`). 

| Nota: Nunca hará consultas relativas a `tudominio.com` en internet, no le hace falta. |

* La configuración se guarda en un par de ficheros, este es un ejemplo de cómo asigno IP's vía DHCP de forma estática usando la dirección hardware MAC del dispositivo.

```console
pihole $ sudo cat /etc/dnsmasq.d/04-pihole-static-dhcp.conf
dhcp-host=52:54:12:12:12:12,192.168.100.1,muro.tudominio.com
dhcp-host=00:08:22:37:0E:A1,192.168.100.2,equipo.tudominio.com

dhcp-host=38:34:D3:3E:DA:31,192.168.100.50,nodo1.tudominio.com
dhcp-host=38:F9:34:B7:36:96,192.168.100.51,nodo2.tudominio.com
```

* Asigno nombres DNS a direcciones IP.
  
```console
pihole $ sudo cat /etc/pihole/custom.list
192.168.100.1 muro.tudominio.com
192.168.100.2 equipo.tudominio.com
:
192.168.100.50 nodo1.tudominio.com
192.168.100.51 nodo2.tudominio.com
:
192.168.100.224 pihole.tudominio.com
```

* Cuando modifico los ficheros rearranco pihole

```console
pihole $ sudo pihole restartdns
```

<br/>

#### Proxy Inverso

Un proxy inverso es un servidor que actúa como intermediario entre los usuarios y los servidores web que hay detrás de él. Cuando hago una solicitud a un sitio web (de mi intranet), en lugar de enviar la solicitud directamente al servidor web, se envía al proxy inverso y este a su vez al servidor web correspondiente.

Tengo varios servicios que administro vía Navegador y me gustaría conectar vía `https` con certificados válidos generados con [Let's Encrypt](https://letsencrypt.org/es/). Es obligatorio solicitar un certificado para cada nombre, por lo tanto necesito tener dados de alta esos "nombres" en mi proveedor DNS de internet, porque Let's Encrypt necesita verificar que soy el propietario. 

**Configuración DNS**

Lo primero entonces es dar de alta los nombres de subdominio en mi proveedor DNS de internet (dinámico) y ya de paso en mi Servidor DNS/DHCP interno (PiHole). 

- En Internet (proveedor de DNS dinámico): Doy de alta registros de tipo 'A' contra el mismo usuario, de modo que al cambiar la IP dinámica de dicho usuario se aplique la misma IP a todos; es decir, todos resolverán a mi misma IP pública.

```consola
    git.tudominio.com            Usuario: MiUsuarioEnMiProveedor 
    grafana.tudominio.com        Usuario: MiUsuarioEnMiProveedor
    ha.tudominio.com             Usuario: MiUsuarioEnMiProveedor
    kuma.tudominio.com           Usuario: MiUsuarioEnMiProveedor
    librenms.tudominio.com       Usuario: MiUsuarioEnMiProveedor
    sol.tudominio.com            Usuario: MiUsuarioEnMiProveedor
    tierra.tudominio.com         Usuario: MiUsuarioEnMiProveedor
```

- En Intranet, en el software DNS/DHCP server interno (PiHole), doy de alta los nombres apuntando todos a la misma IP, la interna de mi (futuro) Nginx Proxy Manager.

```consola
    git.tudominio.com            192.168.100.243
    grafana.tudominio.com        192.168.100.243
    ha.tudominio.com             192.168.100.243
    kuma.tudominio.com           192.168.100.243
    librenms.tudominio.com       192.168.100.243
    sol.tudominio.com            192.168.100.243
    tierra.tudominio.com         192.168.100.243
```

<br/> 

**Instalación de Contenedor LXC [Nginx Proxy Manager](https://nginxproxymanager.com)** 

Uso NPM como Proxy Inverso porque es muy rápido, ligero y además soporta lo que necesito: Proxy Inverso con soporte de `https`, gestión de Certificados SSL con Let's Encrypt y Port Forwarding (lo llama Streams).

* Creo un contenedor LXC en Proxmox VE [mediante un Helper Script](https://tteck.github.io/Proxmox/): 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-13.png"
    caption="Instalación de Contenedor LCX usando un Helper Script"
    width="700px"
    %} 

Desde la consola de uno de mis Host lanzo el proceso de instalación: 

```console
root@pve-sol:~# LANG=C bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/nginxproxymanager.sh)"
```

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-14.png"
    caption="Contesto todas las preguntas y se crea el Contenedor LCX"
    width="800px"
    %} 

Hago la configuración a través de su interfaz Web

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-15.png"
    caption="He dado de alta varios Proxy Hosts y un Stream"
    width="600px"
    %} 

* Definición de los Proxy Hosts

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-16.png"
    caption="Lista de Proxy Hosts"
    width="600px"
    %} 


* El Proxy Host de Home Assistant he hecho una configuración personalizada para que funcione correctamente Visual Studio Code Server. 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-20.png"
    caption="Configuración de un port forwarding"
    width="400px"
    %} 

* Configuración de Certificados con Let's Encrypt. 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-17.png"
    caption="Lista de Certificados vía Let's Encrypt"
    width="600px"
    %} 

Para poder crear los certificados y para poder renovarlos cada 3 meses necesitas que Let's Encrypt valide que eres quien dices ser. Utiliza dos métodos y dependiendo de qué soporte tu proveedor de dominios deberás usar uno u otro. 

- DNS Challenge: Este método es el mejor, no necesitas abrir ningún puerto en tu router, pero *tu proveedor DNS tiene que estar en la lista de los soportados por Let's Encrypt*. Si no está o no puedes crear registros TXT dinámicamente en tu proveedor entonces tienes que usar el siguiente método: 
- Manual: Este método necesita que abras, al menos temporalmente, el puerto 80 en tu router y firewall, además necesitas que tu proveedor DNS resuelva correctamente el subdominio sobre el cual quieres solicitar el certificado.

En mi caso tengo que usar el segundo (Manual) y uso un par de scripts. Antes de solicitar o renovar el certificado abro el port-forwarding ejecutando `open-npm-letsencryp.sh` desde mi router/firewall. Una vez que están todos hecho lo vuelvo a cerrar con `close-npm-letsencrypt.sh`.

- [open-npm-letsencrypt.sh](https://gist.github.com/LuisPalacios/3cff94bf807965b448d59523537eb9a6)
- [close-npm-letsencrypt.sh](https://gist.github.com/LuisPalacios/c10af93c6d3be7b1c5796899ad57d3f4)

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-22.png"
    caption="Tipo de comunicación con Let's Encrypt"
    width="600px"
    %} 

* Todos los Proxy Hosts tienen activo el Websockets Support y Force SSL en el Certificado

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-19.png"
    caption="Configuración de un port forwarding"
    width="600px"
    %} 

* Configuración de un Stream (Port Forwarding)

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-18.png"
    caption="Configuración de un port forwarding"
    width="600px"
    %} 

¿Qué es esto de Port Forwarding para mi servidor Git?. Pues que si quiero usar el mismo nombre DNS para hacer `https` para la administración y `ssh` para sincronizar los repositorios, tengo que hacer un pequeño invento. Consiste en dar de alta un Proxy Host para la parte `https` y un Port Forwarding (Stream) para la parte de `ssh`. Así paso a tener disponible `https://git.tudominio.com` y `git@git.tudominio.com:privado/repositorio.git` para hacer commits, etc. Además me permite (previo knock, knock) acceder desde internet. 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-21.png"
    caption="Detalle del port forwarding"
    width="300px"
    %} 


Cuando conecto desde Internet, con cualquiera de los tres primeros, vía `https`, conectaré con mi IP pública, me dejará entrar porque he llamado previamente a la puerta con `knockd` (como vimos en la sección de Internet), y mi router/firewall hace port-forwarding hacia NPM (Nginx Proxy Manager), que gracias al nombre que viene en la petición https reenvía a su vez hacia la IP del servicio concreto en la Intranet.

Cuando estoy en casa y conecto desde la Intranet, con cualquiera de esos nombres o de los adicionales vía `https`, mi DNS Server interno resuelve a la IP interna de mi NPM (Nginx Proxy Manager), que por el nombre me deriva a su vez al servicio concreto.


<br/>
