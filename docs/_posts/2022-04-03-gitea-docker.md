---
title: "Gitea y Traefik en Docker"
date: "2022-04-03"
categories: desarrollo
tags: linux git servidor gitea gitlab github traefik smtp
excerpt_separator: <!--more-->
---

![Logo gitea traefik docker](/assets/img/posts/logo-gitea-docker.svg){: width="150px" style="float:left; padding-right:25px" } 

En este apunte describo la instalación de [Gitea](http://gitea.io) (servidor GIT) y [Traefik](https://doc.traefik.io/traefik/) (terminar certificados SSL de LetsEncrypt). Ambos corriendo como contenedores Docker en una máquina virtual basada en Alpine Linux.

<br clear="left"/>
<!--more-->

| En otro apunte expliqué qué es Gitea y cómo [montarlo sobre una máquina virtual]({% post_url 2022-03-26-gitea-vm %}). En esta ocasión he añadido Traefik y ejecuto ambos como **contenedores en un Host Docker** que a su vez corre en máquina virtual Alpine Linux sobre mi Hypervisor QEMU/KVM. Este apunte refleja mi instalación en producción en mi red casera. Doy crédito al autor de este fantástico artículo: [setup a self-hosted git service with gitea](https://dev.to/ruanbekker/setup-a-self-hosted-git-service-with-gitea-11ce) |

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-1.jpg" 
      caption="Arquitectura de los microservicios" 
      width="450px"
      %}


### Networking

Antes de entrar en harina mejor entender cual es la configuración del networking de mi instalación casera: 

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-2.jpg" 
      caption="Configuración del networking" 
      width="600px"
      %}

Este tipo de instalación permitirá conectar con el servidor `gitea` localmente (en la red LAN) pero también desde Internet (necesario también para recibir el certificado SSL de Letsencrypt). Normalmente abro los puertos de internet solo bajo demanda, para renovar el certificado o bien cuando quiero usar el servicio desde internet. Para abrir los puertos ejecuto lo siguiente en el router:

```console
export GITIP=192.168.1.200
iptables -t nat -I PREROUTING -i ppp0 -p tcp -m multiport --dports 22,80,443 -j DNAT --to-destination ${GITIP}
iptables -I FORWARD -p tcp -m multiport --dports 22,80,443 -d ${GITIP} -j ACCEPT
```

En mi proveedor DNS tengo activo el nombre `git.parchis.org` apuntando a mi dirección ip pública (dinámica) y en el Servidor DNS local en mi instalación casera tengo lo siguiente: 

- Traefik: `traefik.parchis.org --> 192.168.1.200`
- Gitea: `git.parchis.org       --> 192.168.1.200`

He configurado el Servicio `openssh` del Alpine Linux para que escuche por otro puerto (22222), de modo que dejo libre el puerto `22` para el contenedor de `gitea`. El acceso a la web se realizara vía `HTTPS` por el puerto `443` y el trabajo con GIT *sobre ssh* se hará a través del puerto `22`.

<br/>

### Máquina virtual con Alpine Linux

El primer paso es la creación de **VM basada en Alpine Linux con todo lo necesario para ejecutar Docker**. Sigo la documentación y el ejemplo descrito en el apunte [Alpine para ejecutar contenedores]({% post_url 2022-03-20-alpine-docker %}). Llamo al equipo `git.parchis.org`.

Una vez que termino la instalación de mi máquina virtual con Alpine Linux he modificado su fichero `/etc/hosts`
```console
127.0.0.1	git.parchis.org git traefik traefik.parchis.org localhost.localdomain localhost
::1		localhost localhost.localdomain
```

Entro en la máquina virtual con mi usuario `luis` y creo el directorio `gitea` donde colocaré todos los ficheros de trabajo para los contenedores de *Traefik* y *Gitea*
```console
git:~$ id
uid=1000(luis) gid=1000(luis) groups=10(wheel),101(docker),1000(luis),1000(luis)
git:~$ pwd
/home/luis
git:~$ mkdir gitea
```

<br/>

### Contenedor Traefik

-  creo el fichero donde se guardará el certificado y le cambio los permisos
```console
git:~/gitea$ mkdir traefik
git:~/gitea$ touch traefik/parchis.json
git:~/gitea$ chmod 600 traefik/parchis.json
```
- Creo el fichero `docker-compose.yml` empezando por el primer serivicio `gitea-traefik`. Cambia tu `Host()` y `TUCORREO@TUDOMINIO.COM` por el adecuado.
```yml
version: '3.9'
services:
  gitea-traefik:
    image: traefik:2.7
    container_name: gitea-traefik
    restart: unless-stopped
    volumes:
      - ./traefik/acme.json:/acme.json
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - public
    labels:
      - 'traefik.enable=true'
      - 'traefik.http.routers.api.rule=Host(`git.parchis.org`)'
      - 'traefik.http.routers.api.entrypoints=https'
      - 'traefik.http.routers.api.service=api@internal'
      - 'traefik.http.routers.api.tls=true'
      - 'traefik.http.routers.api.tls.certresolver=letsencrypt'
    ports:
      - 80:80
      - 443:443
    command:
      - '--api'
      - '--providers.docker=true'
      - '--providers.docker.exposedByDefault=false'
      - '--entrypoints.http=true'
      - '--entrypoints.http.address=:80'
      - '--entrypoints.http.http.redirections.entrypoint.to=https'
      - '--entrypoints.http.http.redirections.entrypoint.scheme=https'
      - '--entrypoints.https=true'
      - '--entrypoints.https.address=:443'
      - '--certificatesResolvers.letsencrypt.acme.email=TUCORREO@TUDOMINIO.com'
      - '--certificatesResolvers.letsencrypt.acme.storage=acme.json'
      - '--certificatesResolvers.letsencrypt.acme.httpChallenge.entryPoint=http'
      - '--log=true'
      - '--log.level=INFO'
    logging:
      driver: "json-file"
      options:
        max-size: "1m"
networks:
  public:
    name: public
```
- Arranco el servicio
```console
git:~/gitea$ docker-compose up -d
WARNING: Network public not found.
Creating network "public" with the default driver
Creating gitea-traefik ... done
git:~/gitea$ docker logs -f --since 1h gitea-traefik
time="2022-03-27T08:33:57Z" level=info msg="Configuration loaded from flags."
time="2022-03-27T08:33:57Z" level=info msg="Starting provider aggregator aggregator.ProviderAggregator"
time="2022-03-27T08:33:57Z" level=info msg="Starting provider *traefik.Provider"
time="2022-03-27T08:33:57Z" level=info msg="Starting provider *docker.Provider"
time="2022-03-27T08:33:57Z" level=info msg="Starting provider *acme.ChallengeTLSALPN"
time="2022-03-27T08:33:57Z" level=info msg="Starting provider *acme.Provider"
time="2022-03-27T08:33:57Z" level=info msg="Testing certificate renew..." providerName=letsencrypt.acme ACME CA="https://acme-v02.api.letsencrypt.org/directory"
```
- Una vez que tenga traefik funcionando amplío la configuración para añadir el resto de servicios.

<br/>

### Contenedores Gitea y Redis

- Preparo el directorio donde dejaré los datos de GIT
```console
git:~/gitea$ mkdir -p data/gitea
```
- Añado al fichero `docker-compose.yml` dos servicios más, el servicio `gitea` y el servicio de caché `redis`. Además haré uso de `MySQL`.
- Revisa las siguientes opciones de configuración:
  - DOMAIN y SSH_DOMAIN (urls para hacer clone con git)
  - ROOT_URL (Configurado para usar HTTPS, incluyendo mi dominio)
  - SSH_LISTEN_PORT (este es el puerto de escucha para SSH dentro del contenedor)
  - SSH_PORT (Puerto que expongo hacia el exterior y se usará para el clone)
  - DB_TYPE (Tipo de Base de Datos)
  - traefik.http.routers.gitea.rule=Host() (cabecera para llegar a gitea vía web)
  - ./data/gitea (Ruta para la persistencia de los datos. En mi caso utilizo dejo los datos dentro de la máquina virtual)
- Así es como queda el fichero final: 
```yml
version: '3.9'
services:
  gitea-traefik:
    image: traefik:2.7
    container_name: gitea-traefik
    restart: unless-stopped
    volumes:
      - ./traefik/acme.json:/acme.json
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - public
    labels:
      - 'traefik.enable=true'
      - 'traefik.http.routers.api.rule=Host(`git.parchis.org`)'
      - 'traefik.http.routers.api.entrypoints=https'
      - 'traefik.http.routers.api.service=api@internal'
      - 'traefik.http.routers.api.tls=true'
      - 'traefik.http.routers.api.tls.certresolver=letsencrypt'
    ports:
      - 80:80
      - 443:443
    command:
      - '--api'
      - '--providers.docker=true'
      - '--providers.docker.exposedByDefault=false'
      - '--entrypoints.http=true'
      - '--entrypoints.http.address=:80'
      - '--entrypoints.http.http.redirections.entrypoint.to=https'
      - '--entrypoints.http.http.redirections.entrypoint.scheme=https'
      - '--entrypoints.https=true'
      - '--entrypoints.https.address=:443'
      - '--certificatesResolvers.letsencrypt.acme.email=TUCORREO@TUDOMINIO.com'
      - '--certificatesResolvers.letsencrypt.acme.storage=acme.json'
      - '--certificatesResolvers.letsencrypt.acme.httpChallenge.entryPoint=http'
      - '--log=true'
      - '--log.level=INFO'
    logging:
      driver: "json-file"
      options:
        max-size: "1m"
  gitea:
    container_name: gitea
    image: gitea/gitea:1.16
    restart: unless-stopped
    depends_on:
      gitea-traefik:
        condition: service_started
      gitea-cache:
        condition: service_healthy
    environment:
      - APP_NAME="Gitea"
      - USER_UID=1000
      - USER_GID=1000
      - USER=git
      - RUN_MODE=prod
      - DOMAIN=git.parchis.org
      - SSH_DOMAIN=git.parchis.org
      - HTTP_PORT=3000
      - ROOT_URL=https://git.parchis.org
      - SSH_PORT=22
      - SSH_LISTEN_PORT=22
      - DB_TYPE=sqlite3
      - GITEA__cache__ENABLED=true
      - GITEA__cache__ADAPTER=redis
      - GITEA__cache__HOST=redis://gitea-cache:6379/0?pool_size=100&idle_timeout=180s
      - GITEA__cache__ITEM_TTL=24h
    ports:
      - "22:22"
    networks:
      - public
    volumes:
      - ./data/gitea:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.gitea.rule=Host(`git.parchis.org`)"
      - "traefik.http.routers.gitea.entrypoints=https"
      - "traefik.http.routers.gitea.tls.certresolver=letsencrypt"
      - "traefik.http.routers.gitea.service=gitea-service"
      - "traefik.http.services.gitea-service.loadbalancer.server.port=3000"
    logging:
      driver: "json-file"
      options:
        max-size: "1m"
  gitea-cache:
    container_name: gitea-cache
    image: redis:6-alpine
    restart: unless-stopped
    networks:
      - public
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 15s
      timeout: 3s
      retries: 30
    logging:
      driver: "json-file"
      options:
        max-size: "1m"
networks:
  public:
    name: public
```
- Paro Traefik 
```console
git:~/gitea$ docker-compose stop
``` 
```console
git:~/gitea$ docker-compose up -d
Creating network "public" with the default driver
Creating gitea-traefik ... done
Creating gitea-cache   ... done
Creating gitea         ... done
:
git:~/gitea$ docker-compose ps
    Name                   Command                  State                                       Ports
--------------------------------------------------------------------------------------------------------------------------------------
gitea           /usr/bin/entrypoint /bin/s ...   Up             0.0.0.0:22->22/tcp,:::22->22/tcp, 3000/tcp
gitea-cache     docker-entrypoint.sh redis ...   Up (healthy)   6379/tcp
gitea-traefik   /entrypoint.sh --api --pro ...   Up             0.0.0.0:443->443/tcp,:::443->443/tcp, 0.0.0.0:80->80/tcp,:::80->80/tcp
```
- Puedes ver los `logs` de los servicios con: 
```console
git:~/gitea$ docker-compose logs
:
```

<br/>

### Instalación y configuración de Gitea

Lo siguiente lo realizo todo desde la red local de mi casa. Me dirijo a mi `ROOT_URL`, `https://git.parchis.org` y entro en la configuración inicial (que aparece ya preparada)

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-3.png" 
      caption="Conecto con https://git.parchis.org" 
      width="600px"
      %}

- Configuro la parte del correo. Uso mi cuenta de GMail con contraseña de aplicación. 

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-4.png" 
      caption="Configuración del correo" 
      width="600px"
      %}

- Configuro al usuario administrador

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-5.png" 
      caption="Configuración de la cuenta de administrador" 
      width="600px"
      %}

- Hacemos click in "Instalar Gitea". Cuando termina vuelvo a escribir la `ROOT_URL` y deberías ver lo siguiente al estar ya autenticado.

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-6.png" 
      caption="Conecto con https://git.parchis.org" 
      width="600px"
      %}

- Si intento conectar desde INTERNET con con `http://git.parchis.org` me redirige a `https://git.parchis.org` y veré lo siguiente

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-7.png" 
      caption="Página al conectar desde Internet con https://git.parchis.org" 
      width="600px"
      %}

- Si intento conectar con `ssh luis@git.parchis.org` me redirige al contenedor de gitea y su puerto `22`, pero veré un error de permisos, dado que todavía no he configurado SSH.
```console
luis@git.parchis.org: Permission denied (publickey).
```

<br/>

### Configuración de la clave SSH

Creo una clave SSH para poder autorizar a mi cliente git a hacer push/pull/commit a/desde Gitea. Aquí un ejemplo sin contraseña. Copio la clave pública para añadirla a gitea.

```console
$ ssh-keygen -f ~/.ssh/id_gitea -t rsa -C "Gitea" -q -N ""
$ cat .ssh/id_gitea.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDjQxGLslvGHPty3i+NbsY7krjcY/e/JDJ7B+Svpc1DaY8PGCMTegy95PDZf91yoSe39nEq3MVVP8YpMop/gH0WbC8UQO9vI9BTLy1sv+vlGnf+do3h2hsqPrJCuhyPWWLKYzaieXmWHT06Bbwfl9pqOGKxKrqU9+uzn+pGu+cXqSngDBX4Gd4yaJERL/7lprXybT19+lMKKoYddlomv5nNcT3f4r+OW9YYvgQs8UL8a2JwVk++RCL2cIXSG//D25RN/0HVX0twJZoOwg+apWx9nEYNeazVCJlJwhQZOLE2VH1WClWy5YNwXz04wmzjGmtKMf8gtqduiSJV1Xuh6zcgmJ9iv/Qayu18JqUPTHA0CErdWcDC68kaoTQlOht9ZTHyoy4wXNyB1hQnv+kT1IQUvM9mJQIDbgrqUdlZXSRL3CLHC9IImRaHG9mp0eGxb7ZtgEeuumMFhI0NNJwX6YCbbRcfAQgS8DBiyxPLKyjMnV1SLDnMbZJth0gjj9eXKUM= Gitea
```

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-8.png" 
      caption="En la sección de preferencias del usuario" 
      width="600px"
      %}

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-9.png" 
      caption="Añado la clave pública" 
      width="600px"
      %}

<br/>

### Crear un repositorio público.

Vuelvo a la página web y creo creo el repositorio `hola-mundo`

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-10.png" 
      caption="Añadir repositorio" 
      width="600px"
      %}
{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-11.png" 
      caption="Creo el repositorio hola-mundo" 
      width="600px"
      %}

Antes de poder trabajar con el repositiorio configuro mi cliente (`$HOME/.ssh/config`) y añado lo siguiente: 

```config
# Gitea
Host git.parchis.org
  IdentityFile ~/.ssh/id_gitea
  User git
  Port 22
```

A partir de ahora ya puedo hacer clone, push, pull, etc... 
```console
$ git clone git@git.parchis.org:luis/hola-mundo.git
Cloning into 'hola-mundo'...
X11 forwarding request failed
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (3/3), done.
```

<br/>

### Swagger API

Gitea viene con Swagger por defecto y el endpoint es `/api/swagger`

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-12.png" 
      caption="Conecto con Swagger" 
      width="600px"
      %}

<br/>

----

