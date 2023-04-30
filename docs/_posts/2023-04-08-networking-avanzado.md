---
title: "Domótica y Networking"
date: "2023-04-08"
categories: administración
tags: domótica networking avanzado linux pve proxmox kvm qemu cloud-init alpine debian ubuntu plantilla virtualización
excerpt_separator: <!--more-->
---


![logo linux router](/assets/img/posts/logo-homenet.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Comparto mi **networking doméstico avanzado**, resiliente, funcional y con una buena experiencia de usuario, incluso tengo la opción de *llamar a la puerta* desde Internet para accesos puntuales. No queda más remedio, las redes caseras de hoy en día acaban soportando múltiples servicios y con la irrupción de la domótica se múltiplican.  

La domótica hace crecer exponencialmente el número de dispositivos y mantener la red de un hogar inteligente y automatizado es cada día más difícil. Este apunte está dedicado a esos *Geeks* y *Techys* que, como yo, llevamos ya tiempo metidos en la *complicación de una red casera domotizada*.


<br clear="left"/>
<!--more-->
 
 
## Punto de partida

¿A que me refiero con **networking avanzado**?. Pues que soporte de forma resiliente y segura *muchos cacharros variopintos*, vía LAN/WiFi y puntualmente desde internet. Que pueda usar certificados para trabajar con `https`, que incluya la domótica y ya por pedir, que siga funcionando si cae internet o la WiFi (por lo menos la mayoría de las cosas).

¿Cuanto puede crecer tu red? pues si sumamos switches, AP's, servidores físicos, virtuales, sensores, relés, actuadores, etc. yo veía el otro día 122 IP's únicas.

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

Hasta que necesitas algo más, en ese caso mi **recomendación es poner detrás mi propio router + switch(es) + AP(s)** y desactivar el WiFi del Proveedor 😆. Partiendo de esta premisa, tenemos tres opciones (ojo!, mi proveedor es movistar, si tienes otro habrá ligeros cambios):

<br/>

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-02.svg"
    caption="Arquitectura funcional: para un control total mejor poner mi router"
    width="800px"
    %} 

<br/>

- **Estándar**: Conecto mi Router al del Proveedor y recibo IP privada (`192.168.1.0/24`).
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

Yo monto un **Linux** sobre máquina virtual, uso el **routing nativo con `iptables`** para hacer la parte de firewall. Conmuta el tráfico entre la sesión `pppoe (vlan6)` y la `vlan` de mi Intranet. Deniego todo el tráfico de entrada y hago `MASQUERADE` para salida. Se comporta exáctamente igual que el router de movistar. Utilizo IP pública dinámica y actualizo dinámicamente mi dominio.

| La diferencia es que puedo **hacer más cosas con un control total**: montar un sistema para llamar a la puerta y  abrir puertos bajo demanda a IP específica, openvpn de forma controlada, evitar que se conteste a los pings, identificar intentos de ataques, controlar el tráfico VoIP, controlar el tráfico IPTV, ... |

Otra opción es montar distribuciones dedicadas a esto, las más conocidas son [OpenWrt](https://openwrt.org), [IPFire](https://www.ipfire.org) o [pfSense](https://www.pfsense.org) (solo intel), con la ventaja de estar muy probadas y tener un interfaz gráfico de configuración. Otra es pasarte a hardware dedicado, como Mikrotik u otros.

Por último, una opción muy barata es usar una Raspberry Pi 4B de 1GB con Raspberry Pi OS 64bits, su routing nativo + `iptables` o instalarle una imagen de [OpenWrt](https://openwrt.org) o [IPFire](https://www.ipfire.org). Ojo, necesitarás un Switch (mínimo iría a uno de 8xGbe con soporte de VLAN's e IGMP) y uno o más AP's que soporten Roaming para la WiFi.

En mi caso, como decía, un Linux a pelo, como máquina virtual en host ([Proxmox VE](https://www.proxmox.com/en/proxmox-ve)) en un NUC de Intel. En realidad hace poco lo convertí en un Cluster Proxmox formado por 2xNUC's + una Pi3B para tener mejor tolerancia a fallos de mis servicios caseros. 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-03.svg"
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
        - 192.168.1.1/22                 <== Mi IP en la intranet
        nameservers:
          addresses:
          - 192.168.1.224                <== El DNS/DHCP server
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
    src="/assets/img/posts/2023-04-15-networking-avanzado-04.png"
    caption="Configuro la tarjeta para que reciba el TRUNK"
    width="600px"
    %} 

Para que el router `muro` reciba el Trunk basta con dejar vacío el campo `VLAN Tag`. También **recomiendo quitar la opción `Firewall` en las opciones** (aunque lo tengas desactivado a nivel global en Proxmox). A mi me dió problemas el `IGMP` mullticast.

Una vez que lo tengo configurado paso a tener una VM que me hace Routing + Firewall entre múltiples redes.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-05.svg"
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


Recuerda habilitarlos. 

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

El dominio que tengo en internet (ej.: `tudominio.com`) está siendo servido por mi proveedor de DNS en Internet y en él tengo dados de alta varios registros de tipo `'A'` con los nombres de mis servicios, por ejemplo, Home Assistant -> `ha.tudominio.com`, SSH -> `ssh.tudominio.com`, OpenVPN -> `vpn.tudominio.com`. Todos resolverán a la misma IP Pública de mi servidor. 


Veremos en la seccción de la Intranet -> DNS/DHCP que sirvo exactamente el mismo dominio (`tudominio.com`) desde mi servidor internet, de modo que estes dondes estés (internet o intranet) se resuelve siempre el nombre, bien con una IP pública (cuando se consulta a mi proveedor dns) o una privada (cuando se consulta a mi PiHole). 

De momento muestro cómo está configurada la parte de Internet: 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-06.svg"
    caption="Cómo hago la resolución de nombres"
    width="800px"
    %} 

<br/>

#### Llamar a la puerta

El **Port Knocking** es una técnica que consiste en enviar varios paquetes al Router/Firewall para que reconozca que estás "llamando a la puerta" y te abra temporalmente uno o más puertos, pero solo a la IP desde la que estás llamando. 


{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-07.jpg"
    caption="Aplicaciones involucradas"
    width="300px"
    %} 
    
Uso **PortKnock** (App para smartphone): lanza la petición (1) "Ábreme el puerto para llegar a Home Assistant", envía una serie de paquetes con una cadencia determinada; el router/firewall se da por enterado y abre durante un rato el puerto `28123` (2) para que **Home asistant** pueda entrar. 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-08.svg"
    caption="Así funciona *Llamar a la puerta*"
    width="800px"
    %} 

Lo tengo configurado para que conecte siempre con `mihass.midominio.com` que se resuelve tanto en Internet (con la IP del dominio dinámico) como en la Intranet (con la IP interna, lo veremos más adelante).

Podemos configurar cuantos toques se dan a la puerta y a qué número de puertos. Deben coincidir en el servidor y cliente. Por ejemplo, dar tres toques cada segundo sería así: Envía un `SYN` al puerto #1, espera un segundo, un `SYN` al puerto #2, espera otro segundo y envía un último `SYN` al puerto #3. En ese instante nuestro daemon `knockd` ejecuta lo que queramos, que será típicamente `iptables` para abrir el puerto (`28123` en este ejemplo).

**Instalación**
  
```console
root@muro:~# apt install knockd
```

Aquí tienes un ejemplo del fichero de configuración, obviamente con números inventados. Cámbia los puertos de llamada, los puertos de tu servidor, la cadencia, etc. Así tendrás una configuraicón prácticamente imposible de descubrir. 

- [/etc/knockd.conf](https://gist.github.com/LuisPalacios/6132bb17999934f5eb51cf186d94910f)

Podrías complicarlo más aún. Imagina un proceso que cada semana te cambia los puertos, tanto en el cliente como en el servidor, de forma aleatoria. Ahí sí que se lo has puesto difícil a cualquiera que intente averiguar cuando y por dónde abres en tu firewall.

**Activación del servicio**

```console
root@muro:~# systemctl enable knockd
```

<br/>

#### OpenVPN

Como VPN Server utilizo [OpenVPN](https://openvpn.net/) que sigue siendo la mejor solución hoy en día, a pesar de que es más complejo de implementar. El objetivo es poder tener acceso a los servicios internos de mi red casera desde internet. Es fiable, rápido y lo más importante, muy seguro. Como contrapartida, su configuración es más compleja y tiene el inconveniente de necesitar un software adicional en los clientes.

Hay mucha documentación sobre cómo instalar OpenVPN, en [OpenVPN Server]({% post_url 2014-09-14-vpn-server-en-linux %}) tienes un apunte antiguo que hice sobre el tema. 

Como cliente utilizo [Passepartout](https://passepartoutvpn.app/). Necesitamos abrir un puerto (típicamente en UDP) y hay dos formas de hacerlo. 

* Dejar siempre un puerto abierto. Aunque OpenVPN es muy seguro prefiero no hacerlo. Si quieres implementaro, esto es lo que iría en el fichero [firewall_1_pre_network.sh](https://gist.github.com/LuisPalacios/b648ef38206caa8c28cbc148a89ff364).

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

* Abrir un puerto bajo demanda con el método de **Llamar a la puerta**. Esta es mi opción, no dejas nada abierto. Tal como describí con el ejemplo con Home Assistant, hago lo mismo para entrar por IPSec; llamo a la puerta ([/etc/knockd.conf](https://gist.github.com/LuisPalacios/6132bb17999934f5eb51cf186d94910f)), se abre el canal contra el OpenVPN y arranco mi cliente Passepartout.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-09.svg"
    caption="Uso knockd para abrir el puerto del servidor OpenVPN"
    width="500px"
    %} 

<br/>

----

<br/>

### Intranet

Vamos bajando por la casa, estos son los servicios que tengo activos: 

- Servicios de Networking: Además de lo que hemos visto en la sección anterior configuro: Uno o más Switches y uno o más Access Points. Además un Servidor DHCP y DNS, en mi caso un controlador de AP's, un Proxy Inverso y algunas herramientas (opcionales) de monitorización (como Gatus, Uptime Kuma, LibreNMS, Netdisco). 

- Servicios de domótica: El networking de la casa está soportando Home Assistant, Node-RED, Zigbee2MQTT, Mosquito, Grafana e InfluxDB. Permiten controlar y automatizar diferentes dispositivos en el hogar, como la iluminación, los sistemas de climatización, sensores, luces, enchufes, relés, las cerraduras y los electrodomésticos. La gran mayoría utilizan WiFi y algunos Zigbee (que no es objeto de este apunte).

- Servicios adicionales: Además soporta un QNAP para hacer backups y un servidor GIT que permite alojar y compartir proyectos de software y configuraciones. Por no mencionar laboratorios para aprender.

Recomiendo, aunque parezca obvio decirlo, montar todo con Switches con puertos de 1Gbe y equipos (AP's) WiFi que soporten la mayor velocidad que podáis. Hoy en día con la posibilida de fibra a 1Gb con Internet esa es la mínima velocidad que tenemos que soportar en casa. La WiFi (casera) ya está llegando a esas velocidades. 

<br/>


#### Servidor o Servidores

Son varios los servicios de software y se pueden montar todos en el mismo Hardware. Yo recomiendo hacerlo todo con máquinas virtuales o contenedores (Docker o LXC) o una mezcla de ambos. Tras haber trabajado durante años con un Host Linuxc on KVM/QEMU he optado por irme a Proxmox VE y como tenía un NUC aditional y una PI3B antiguos, pues he optado por montar un Cluster. 

Cuando se me caía el "host" con mis VM's me quedaba sin casa 😂 y me caía la bronca, así que ahora tengo un par de Host (2xNUC's + 1xPi) formando un Cluster Proxmox VE para hospedar las máquinas virtuales, contenedores LXC o Docker con servicios. La Pi es una Pi3B que hace que el Cluster "negocie bien" la tolerancia a fallos.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-10.jpg"
    caption="Como decía, llevo tiempo complicando mi instalación"
    width="600px"
    %} 

<br/>

#### DNS y DHCP

Como servidor DNS y DHCP utilizo desde hace tiempo Pi-hole como máquina virtual, porque no solo me ofrece eso, sino que además hace de sumidero de la publicidad no deseada. Tengo un apunte dedicado a cómo instalar un [Pi-hole casero]({% post_url 2021-06-20-pihole-casero %}).

![logo pihole](/assets/img/posts/logo-pihole.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 

Mantengo en un excel la lista de equipos, MACs y la IP que les asigno, una CMDB muy casera y así tengo al día el par de ficheros donde se guardan las asignaciones para el DHCP y los nombres DNS.

ya lo había mostrado pero es importante recordarlo, esta es la forma en la que funciona la resolución de nombres. En internet mi dominio `tudominio.com` está siendo servido por mi proveedor de DNS. En la Intranet mi `tudominio.com` está siendo servidor por PiHole.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-11.svg"
    caption="Cómo hago la resolución de nombres"
    width="800px"
    %} 


Cuando alguien de la Intranet pide un nombre SIEMPRE preguntan a mi PiHole. O bien tiene la IP privada (si es una consulta a `tudominio.com`) o bien se va a internet a por la IP. Nunca hará consultas relativas a `tudominio.com` en internet, no le hace falta. 

* La configuración se guarda en un par de ficheros, este es un ejemplo de cómo asigno IP's vía DHCP de forma estática (por la MAC)

```console
$ sudo cat /etc/dnsmasq.d/04-pihole-static-dhcp.conf
dhcp-host=52:54:12:12:12:12,192.168.1.1,muro.tudominio.com
dhcp-host=00:08:22:37:0E:A1,192.168.1.2,equipo.tudominio.com

dhcp-host=38:34:D3:3E:DA:31,192.168.1.50,nodo1.tudominio.com
dhcp-host=38:F9:34:B7:36:96,192.168.1.51,nodo2.tudominio.com
```

* Asigno nombres DNS a direcciones IP.
  
```console
$ sudo cat /etc/pihole/custom.list
192.168.1.1 muro.tudominio.com
192.168.1.2 equipo.tudominio.com
:
192.168.1.50 nodo1.tudominio.com
192.168.1.51 nodo2.tudominio.com
:
192.168.1.224 pihole.tudominio.com
```

* Cuando modifico los ficheros rearranco pihole

```console
$ sudo pihole restartdns
```

<br/>

#### Proxy Inverso

Utilizo **[Nginx Proxy Manager](https://nginxproxymanager.com)**.

PENDIENTE de terminar 


**Acceso a múltiples hosts vía `https`**

Un caso donde puedes es necesario dar de alta múltiples registros de tipo 'A' en el dominio externo es, por ejemplo, cuando necesito conectar con `https` a verios servicios de casa. En mi caso he montado un Proxy inverso con Nginx Proxy manager, tengo varios servicios que se administran vía Web,  y he solicitado certificados con Let's Encrypt. 

Un ejemplo, con cuatro servicios: 

- `https://mihass.midominio.com`
- `https://migitea.midominio.com`
- `https://milibrenms.midominio.com`
- `https://miproxmox.midominio.com`. 

Quiero entrar desde Internet y la Intranet. ¿Cómo lo configuro?

- En Internet (proveedor de DNS dinámico): Doy de alta 4 x registros de tipo 'A' contra el mismo usuario, de modo que al cambiar la IP dinámica de dicho usuario, me aplica a los cuatro. A todos los efectos, los cuatro subdominios resuelven a mi misma IP pública. 
- En Intranet, mi software DNS/DHCP server interno (PiHole, que veremos luego) tiene dados de alta los cuatro apuntando a la misma IP, la interna de mi Nginx Proxy Manager.

Cuando conecto desde Internet, con cualquiera de esos nombres, vía `https`, todos conectan con mi IP pública, me dejará entrar porque he llamado previamente a la puerta con `nockd` (ver siguiente punto), y mi router/firewall hace port-forwarding hacia mi proxy inverso, que por el nombre me deriva a su vez al servicio concreto.

Cuando conecto desde la Intranet, con cualquiera de esos nombres, vía `https`, mi DNS Server interno resuelve a la IP interna de mi proxy inverso, que por el nombre me deriva a su vez al servicio concreto.

PENDIENTE de terminar 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-XX.svg"
    caption="Servidores DNS y conexiones `https`"
    width="500px"
    %} 


<br/>

#### Monitorizacion: Librenms

https://www.librenms.org

PENDIENTE de terminar 

<br/>

#### Monitorizacion: Netdisco

http://netdisco.org

PENDIENTE de terminar 

<br/>

#### Monitorizacion: Gatus

https://github.com/TwiN/gatus

PENDIENTE de terminar 

