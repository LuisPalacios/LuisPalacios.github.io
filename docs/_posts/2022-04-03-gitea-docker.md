---
title: "Gitea y Traefik en Docker"
date: "2022-04-03"
categories: desarrollo
tags: linux git servidor gitea gitlab github traefik smtp
excerpt_separator: <!--more-->
---

![Logo gitea traefik docker](/assets/img/posts/logo-gitea-docker.svg){: width="150px" style="float:left; padding-right:25px" } 

En este apunte describo la instalación de [Gitea](http://gitea.io) (servidor GIT) y [Traefik](https://doc.traefik.io/traefik/) (terminar certificados SSL de LetsEncrypt), junto con [Redis](https://redis.io) (cache) y [MySQL](https://www.mysql.com) (DB). Todos como contenedores Docker en una máquina virtual basada en Alpine Linux. En el apunte anterior expliqué qué es Gitea y cómo [montarlo sobre una máquina virtual]({% post_url 2022-03-26-gitea-vm %}).

<br clear="left"/>
<!--more-->

En esta ocasión he añadido Traefik y Redis a la foto y todo ejecutándose como **contenedores en un Host Docker** sobre un Linux ligero (Alpine Linux), a su vez sobre mi Hypervisor QEMU/KVM. Este apunte refleja mi instalación en producción en mi red casera. Crédito va para el autor de esta buena guía, [setup a self-hosted git service with gitea](https://dev.to/ruanbekker/setup-a-self-hosted-git-service-with-gitea-11ce).

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-1.jpg" 
      caption="Arquitectura de los microservicios" 
      width="450px"
      %}

<br/>

### Networking

Antes de entrar en harina ahí va la configuración de networking de mi instalación casera: 

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-2.jpg" 
      caption="Configuración del networking" 
      width="600px"
      %}

Este tipo de instalación permitirá conectar con el servidor en mi red privada (LAN) pero también desde Internet (obligatorio para recibir el certificado SSL de Letsencrypt). Aunque casi siempre lo uso en local, así es como abro los puertos de internet bajo demanda, para renovar el certificado o usar el servicio desde internet puntualmente:

```console
export GITIP=192.168.1.200
iptables -t nat -I PREROUTING -i ppp0 -p tcp -m multiport --dports 22,80,443 -j DNAT --to-destination ${GITIP}
iptables -I FORWARD -p tcp -m multiport --dports 22,80,443 -d ${GITIP} -j ACCEPT
```

En mi proveedor DNS tengo `git.parchis.org` apuntando a mi dirección ip pública (dinámica) y en el Servidor DNS local en mi instalación casera está así: 

- `traefik.parchis.org --> 192.168.1.200`
- `git.parchis.org       --> 192.168.1.200`

He configurado el Servicio `openssh` del Alpine Linux para que escuche por otro puerto (22222), de modo que dejo libre el puerto `22` para git sobre SSH en el contenedor de `gitea`, y el acceso a la web de Gitea se realizara vía `HTTPS` por el puerto `443`.

<br/>

### Máquina virtual con Alpine Linux

El primer paso es la creación de **VM basada en Alpine Linux con todo lo necesario para ejecutar Docker**. Sigo la documentación y el ejemplo descrito en el apunte [Alpine para ejecutar contenedores]({% post_url 2022-03-20-alpine-docker %}). Llamo al equipo `git.parchis.org`.

- Una vez que termino la instalación del Alpine Linux modifico su `/etc/hosts`
```console
127.0.0.1	git.parchis.org git traefik traefik.parchis.org localhost.localdomain localhost
::1		localhost localhost.localdomain
```
- Entro en la VM con mi usuario y creo el directorio `gitea` donde colocaré todos los ficheros de trabajo para los contenedores.
```console
git:~$ id
uid=1000(luis) gid=1000(luis) groups=10(wheel),101(docker),1000(luis),1000(luis)
git:~$ pwd
/home/luis
git:~$ mkdir gitea
```

<br/>

### Contenedor Traefik

Primero voy a crear solo la parte de Traefik, para asegurarme que funciona correctamente.

-  Creo el fichero donde se guardará el certificado de `letsencrypt`.
```console
git:~/gitea$ mkdir data_traefik
git:~/gitea$ touch data_traefik/acme.json
git:~/gitea$ chmod 600 data_traefik/acme.json
```
- Creo `docker-compose.yml`, de momento solo pongo el primer serivicio `gitea-traefik`. Cambia tu `HOST` y `TUCORREO@gmail.com` por el adecuado.
```yml
version: '3.9'
services:
  gitea-traefik:
    image: traefik:2.7
    container_name: gitea-traefik
    restart: unless-stopped
    volumes:
      - ./data_traefik/acme.json:/acme.json
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
- Cuando funciona todo puedo seguir con el resto de servicios

<br/>

### Contenedores Gitea, Redis y MySQL

- Preparo los directorios donde dejaré los datos.
```console
git:~/gitea$ mkdir -p data/gitea      # Directorio para los datos de Gitea
git:~/gitea$ mkdir -p mysql           # Directorio para los datos de MySQL
```
- Añado los tres servicios a `docker-compose.yml`. Lo adapto a mis necesidades: 
  - DOMAIN y SSH_DOMAIN (urls para hacer clone con git)
  - ROOT_URL (Configurado para usar HTTPS, incluyendo mi dominio)
  - SSH_LISTEN_PORT (este es el puerto de escucha para SSH dentro del contenedor)
  - SSH_PORT (Puerto que expongo hacia el exterior y se usará para el clone)
  - DB_TYPE (Tipo de Base de Datos)
  - traefik.http.routers.gitea.rule=Host() (cabecera para llegar a gitea vía web)
  - ./data/gitea (Ruta para la persistencia de los datos. En mi caso utilizo dejo los datos dentro de la máquina virtual)
- Así es como queda el fichero final: 
```yml
# 
# docker-compose.yaml para gitea,traefik,redis y mysql
# 
version: '3.9'
#
# Servicios
#
services:
  # 
  gitea-traefik:
    image: traefik:2.7
    container_name: gitea-traefik
    restart: unless-stopped
    volumes:
      - ./data_traefik/acme.json:/acme.json
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
      - '--certificatesResolvers.letsencrypt.acme.email=TUCORREO@gmail.com'
      - '--certificatesResolvers.letsencrypt.acme.storage=acme.json'
      - '--certificatesResolvers.letsencrypt.acme.httpChallenge.entryPoint=http'
      - '--log=true'
      - '--log.level=INFO'
    logging:
      driver: "json-file"
      options:
        max-size: "1m"    
  #  Gitea
  gitea:
    container_name: gitea
    image: gitea/gitea:1.16.5
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
      - DB_TYPE=mysql
      - GITEA__database__DB_TYPE=mysql
      - GITEA__database__HOST=db:3306
      - GITEA__database__NAME=gitea
      - GITEA__database__USER=gitea
      - GITEA__database__PASSWD=gitea      
      - GITEA__cache__ENABLED=true
      - GITEA__cache__ADAPTER=redis
      - GITEA__cache__HOST=redis://gitea-cache:6379/0?pool_size=100&idle_timeout=180s
      - GITEA__cache__ITEM_TTL=24h
      - GITEA__mailer__ENABLED=true
      - GITEA__mailer__FROM="TUCORREO@gmail.com"
      - GITEA__mailer__MAILER_TYPE=smtp
      - GITEA__mailer__HOST="smtp.gmail.com:465"
      - GITEA__mailer__IS_TLS_ENABLED=true
      - GITEA__mailer__USER="TUCORREO@gmail.com"
      - GITEA__mailer__HELO_HOSTNAME="git.parchis.org"      
    ports:
      - "22:22"
    restart: always
    networks:
      - public
    volumes:
      - ./data_gitea:/data
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
    depends_on:
      - db   
  # Redis
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
  # MySQL
  db:
    image: mysql:8
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=gitea
      - MYSQL_USER=gitea
      - MYSQL_PASSWORD=gitea
      - MYSQL_DATABASE=gitea
    networks:
      - public
    volumes:
      - ./data_mysql:/var/lib/mysql
#
# Networking 
networks:
  public:
    name: public
```

<br/>

#### Arrancar todos los servicios

- Paro Traefik (opcional)
```console
git:~/gitea$ docker-compose stop
``` 
- Arranco todos los microservicios (contenedores)
```console
git:~/gitea$ docker-compose up -d
Creating network "public" with the default driver
Starting gitea-traefik ... done
Starting gitea-cache   ... done
Starting gitea_db_1    ... done
Starting gitea         ... done:
git:~/gitea$ docker-compose ps
    Name                   Command                  State                                       Ports
--------------------------------------------------------------------------------------------------------------------------------------
gitea           /usr/bin/entrypoint /bin/s ...   Up             0.0.0.0:22->22/tcp,:::22->22/tcp, 3000/tcp
gitea-cache     docker-entrypoint.sh redis ...   Up (healthy)   6379/tcp
gitea-traefik   /entrypoint.sh --api --pro ...   Up             0.0.0.0:443->443/tcp,:::443->443/tcp, 0.0.0.0:80->80/tcp,:::80->80/tcp
gitea_db_1      docker-entrypoint.sh mysqld      Up             3306/tcp, 33060/tcp
```
- Cotilleo los `logs` con: 
```console
git:~/gitea$ docker-compose logs
:
```

<br/>

### Parametrizar Gitea

Me dirijo a mi `ROOT_URL`, `https://git.parchis.org` y entro en la configuración inicial.

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-3.png" 
      caption="Conecto con https://git.parchis.org" 
      width="600px"
      %}

- Sección de correo. Uso mi cuenta de GMail con contraseña de aplicación. 

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-4.png" 
      caption="Configuración del correo" 
      width="600px"
      %}


| Si más adelante quieres retocar la configuración puedes hacerlo modificando `/home/luis/gitea/data/gitea/gitea/conf/app.ini`. Recuerda que antes es conveniente parar el contenedor. |

```console
git:~/gitea$ docker-compose stop gitea
git:~/gitea$ nano data/gitea/gitea/conf/app.ini
:
[mailer]
ENABLED        = true
HOST           = smtp.gmail.com:465
FROM           = tucorreo@gmail.com
USER           = tucorreo@gmail.com
PASSWD         = tucontraseñadeaplicación
MAILER_TYPE    = smtp
IS_TLS_ENABLED = true
HELO_HOSTNAME  = git.parchis.org
:
git:~/gitea$ docker-compose start gitea
```

- Configuro el usuario administrador

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-5.png" 
      caption="Configuración de la cuenta de administrador" 
      width="600px"
      %}

- Hacemos click en "Instalar Gitea". Cuando termina vuelvo a escribir la `ROOT_URL` y deberías ver lo siguiente al estar ya autenticado.

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-6.png" 
      caption="Conecto con https://git.parchis.org" 
      width="600px"
      %}

- Si intento conectar desde INTERNET con `http://git.parchis.org` me redirige a `https://git.parchis.org` y veré lo siguiente

{% include showImagen.html 
      src="/assets/img/posts/2022-03-27-gitea-docker-7.png" 
      caption="Página al conectar desde Internet con https://git.parchis.org" 
      width="600px"
      %}

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

Vuelvo a la página web y creo el repositorio `hola-mundo`

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

Antes de poder trabajar con él, configuro mi cliente (`$HOME/.ssh/config`) y añado lo siguiente: 

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

