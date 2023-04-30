---
title: "Node-RED en Docker"
date: "2022-10-01"
categories: domótica
tags: linux homeassistant grafana flujos iot influxdb solax solaxcloud docker
excerpt_separator: <!--more-->
---

![Logo nodered](/assets/img/posts/logo-nodered.svg){: width="150px" style="float:left; padding-right:25px" } 

Node-RED es una herramienta de programación que permite conectar dispositivos Hardware, API's y servicios en la nube, a través de flujos de trabajo creativos. Se hace todo desde el navegador y soporta decenas de nodos própios y terceros. 

Aquí voy a explicar el proceso de instalación, en una máquina virtual con Alpine y Docker por debajo. Si estás interesado, tengo otro apunte describiendo cómo lo [integro con mi *Home Assistant*]({% post_url 2022-10-02-nodered-hass %}).

<br clear="left"/>
<!--more-->

Como decía, instalo [NodeRed](https://nodered.org) como un **contenedor en un Host Docker** corriendo a su vez sobre la distribución ligera Alpine Linux, que a su vez se ejecuta sobre mi Hypervisor QEMU/KVM. Esta es la arquitectura:

{% include showImagen.html 
      src="/assets/img/posts/2022-10-02-nodered-docker-1.jpg" 
      caption="Arquitectura de la instalación" 
      width="400px"
      %}

<br/>


### Máquina virtual con Alpine Linux

Creo una Virtual Machine basada en Alpine Linux con todo lo necesario para ejecutar Docker y la llamo `nodered.tudominio.com`.

| IMPORTANTE: En este enlace tienes la [documentación para instalar Alpine + Docker]({% post_url 2022-03-20-alpine-docker %}). |

- Una vez que termino la instalación verifico su `/etc/hosts`
```console
127.0.0.1	nodered.tudominio.com nodered localhost.localdomain localhost
::1		localhost localhost.localdomain
```
- Entro en la VM con mi usuario (luis) y creo el directorio `nodered` donde colocaré todos los ficheros de trabajo para los contenedores.
```console
nodered:~$ id
uid=1000(luis) gid=1000(luis) groups=1000(luis),10(wheel),18(audio),27(video),28(netdev),101(docker)
nodered:~$ pwd
/home/luis
nodered:~$ mkdir nodered
```

<br/>

### Contenedor NodeRED

El repositorio en Docker Hub se llama [nodered/node-red](https://hub.docker.com/r/nodered/node-red/)

Primero voy a crear solo la parte de Traefik, para asegurarme que funciona correctamente.

-  Creo el directorio de datos para nodered
```console
nodered:~/nodered$ mkdir data_nodered
nodered:~/nodered$ chown  -R luis:luis data_nodered/
```
- Creo `~/.nodered/docker-compose.yml`.

```yml
version: "3.9"

services:
  node-red:
    image: nodered/node-red:3.0.2-18
    container_name: nodered
    restart: unless-stopped
    environment:
      - TZ=Europe/Madrid
    ports:
      - "1880:1880"
    networks:
      - public
    volumes:
      - ./data_nodered:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    logging:
      driver: "json-file"
      options:
        max-size: "1m"

# Networking
networks:
  public:
    name: public
```
- Arranco el servicio
```console
nodered:~/nodered$ docker-compose up -d
:
nodered:~/nodered$ docker-compose logs -f
Attaching to nodered_node-red_1
node-red_1  | 3 Oct 15:38:18 - [info]
node-red_1  |
node-red_1  | Welcome to Node-RED
node-red_1  | ===================
node-red_1  |
node-red_1  | 3 Oct 15:38:18 - [info] Node-RED version: v3.0.2
node-red_1  | 3 Oct 15:38:18 - [info] Node.js  version: v18.7.0
node-red_1  | 3 Oct 15:38:18 - [info] Linux 5.15.71-0-virt x64 LE
node-red_1  | 3 Oct 15:38:18 - [info] Loading palette nodes
node-red_1  | 3 Oct 15:38:18 - [info] Settings file  : /data/settings.js
node-red_1  | 3 Oct 15:38:18 - [info] Context store  : 'default' [module=memory]
node-red_1  | 3 Oct 15:38:18 - [info] User directory : /data
node-red_1  | 3 Oct 15:38:18 - [warn] Projects disabled : editorTheme.projects.enabled=false
node-red_1  | 3 Oct 15:38:18 - [info] Flows file     : /data/flows.json
node-red_1  | 3 Oct 15:38:18 - [info] Creating new flow file
node-red_1  | 3 Oct 15:38:18 - [warn]
node-red_1  |
node-red_1  | Your flow credentials file is encrypted using a system-generated key.
node-red_1  |
node-red_1  | If the system-generated key is lost for any reason, your credentials
node-red_1  | file will not be recoverable, you will have to delete it and re-enter
node-red_1  | your credentials.
node-red_1  |
node-red_1  | You should set your own key using the 'credentialSecret' option in
node-red_1  | your settings file. Node-RED will then re-encrypt your credentials
node-red_1  | file using your chosen key the next time you deploy a change.
node-red_1  |
node-red_1  | 3 Oct 15:38:18 - [info] Server now running at http://127.0.0.1:1880/
node-red_1  | 3 Oct 15:38:18 - [warn] Encrypted credentials not found
node-red_1  | 3 Oct 15:38:18 - [info] Starting flows
node-red_1  | 3 Oct 15:38:18 - [info] Started flows
```

<br/>

### Trabajar con NodeRED

Me dirijo `http://nodered.tudominio.com:1880` y realizo la configuración inicial. Si no tienes experiencia te recomiendo seguir la [documentación oficial de Node-RED](https://nodered.org/docs/).

{% include showImagen.html 
      src="/assets/img/posts/2022-10-02-nodered-docker-2.jpg" 
      caption="Ejecución inicial" 
      width="800px"
      %}


<br/>

#### Añadir nodos a la Paleta

Node-RED viene con un conjunto básico de nodos útiles, pero hay muchos más disponibles tanto en el proyecto Node-RED como en la comunidad en general. Puedes buscar los nodos disponibles en la [biblioteca de Node-RED](http://flows.nodered.org/).

Puedes añadir nodos con `npm install <npm-package-name>` desde la línea de comandos, pero es complicado hacerlo al ejectuarse en un contendor. Es mucho más fácil instalar  nodos directamente en el editor (desde el navegador). 

- Selecciono la opción `Manage palette` del menú principal.

{% include showImagen.html 
      src="/assets/img/posts/2022-10-02-nodered-docker-4.png" 
      caption="Ejecución inicial" 
      width="250px"
      %}

- Voy a la pestaña "Instalar" y **busco** en el catálogo de módulos disponibles y lo instalo.

{% include showImagen2.html 
      src="/assets/img/posts/2022-10-02-nodered-docker-5.png" 
      src2="/assets/img/posts/2022-10-02-nodered-docker-6.png" 
      caption="Busco homeassistant y snmp para instalar integraciones" 
      width="600px"
      %}

- La pestaña "Nodos" muestra todos los módulos que ha instalado, cuáles se están utilizando y **si hay actualizaciones disponibles para alguno de ellos**.

{% include showImagen.html 
      src="/assets/img/posts/2022-10-02-nodered-docker-7.png" 
      caption="Actualización disponible para Home Assistant" 
      width="600px"
      %}


<br/>


#### Actualizaciones futuras del contenedor

- Averiguo versiones disponibles en el [Hub de Docker -> NodeRED (tags)](https://hub.docker.com/r/nodered/node-red/tags)
- Modifico el fichero `docker-compose.yml` y cambio el número de versión, por ejemplo subo desde la `3.0.1` a la `3.0.2`
```yaml
  :
services:
  node-red:
    image: nodered/node-red:3.0.2
    container_name: nodered
  :
```
- Al hacer un pull se baja la versión
```console
nodered:~/nodered$ docker-compose pull nodered
```
- Paro los servicios, elimino los contenedores y vuelvo a arrancarlos.
```console
nodered:~/nodered$ docker-compose down
nodered:~/nodered$ docker-compose up -d
```
- Al conectar con el navegador deberías ver que hizo correctamente la actualización.

<br/>

{% include showImagen.html 
      src="/assets/img/posts/2022-10-02-nodered-docker-3.png" 
      caption="Comprobar la versión" 
      width="250px"
      %}


---
