---
title: "Servicio \"GIT (gitolite)\" en Contenedor Docker"
date: "2014-11-04"
categories: apuntes
tags: docker git gitolite
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/index.html"
    caption="Gitolite"
    width="600px"
    %}

# Instalación

Para poner en marcha un contenedor hay que partir de una "imagen" mínima con el Sistema Operativo, así que mi primera intención fue usar Gentoo, pero desistí porque fui incapaz de encontrar o crear yo mismo una imagen de menos de 750-900MB (lo ideal es quedarse por debajo de 100MB-200MB).

{% include showImagen.html
    src="/assets/img/original/"
    caption=""Host" uso GNU/Linux Gentoo](http://blog.luispa.com/index.php?controller=post&action=view&id_post=27) y para los contenedores desde "[Debian"
    width="600px"
    %}

**Preparar el Host**

{% include showImagen.html
    src="/assets/img/original/874"
    caption="artículo"
    width="600px"
    %}

**Disco de datos persistente en el Host**

Te recomiendo que el directorio donde vas a dejar los repositorios de tu servidor GIT sea un directorio en el Host, externo al contenedor, de modo que sea persistente.

He elegido el directorio /Apps de mi servidor como la raiz donde voy a dejar tanto los scripts como el directorio persistente para los repositorios:

/Apps/
  +--/data   <== Datos de mis servicios (incluido repositorios Git)
  |
  +--/docker <== scripts y ficheros necesarios para docker

De esta forma tengo todo lo importante en un solo sitio "persistente", aunque borre el contenedor o imagen de docker los repositorios se mantienen y podré reinstalar (docker/imagen/contenedor) para tener el servicio funcionando literalmente en 5 minutos...

{% include showImagen.html
    src="/assets/img/original/ff_3_o.jpg"
    caption="undefined"
    width="600px"
    %}

**Usuarios en el Host**

Creo dos usuarios importantes:

- **luis** - Mi usuario, un usuario normal para no tener que usar root
- **git** - Aunque no hace falta creo en el Host el usuario/grupo "git:git" con el mismo UID/GID que tendrá en el contenedor para darle los permisos y propietario al directorio de los repositorios y así tener coherencia dentro y fuera:

**Directorio /Apps**

Asigno mi usuario como propietario de la raiz

 
totobo git # chown luis:luis /Apps
 

**Usuario y grupo git:git**

Para tener coherencia con lo que verán los contenedores:

 
totobo ~ # groupadd -g 1600 git
totobo ~ # useradd -u 1600 -g git -G git -s /sbin/nologin git
 

## Scripts y Dockerfile

En los enlaces siguientes tienes todo lo necesario:

{% include showImagen.html
    src="/assets/img/original/"
    caption="GitHub: base-gitolite](https://github.com/LuisPalacios/base-gitolite) + [Docker Hub Registry: luispa/base-gitolite"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/servicio-gitolite"
    caption="servicio-gitolite"
    width="600px"
    %}

Solo tienes que bajarte este último:

 
totobo ~ $ cd /Apps/docker/
totobo docker $ git clone https://github.com/LuisPalacios/docker-gitolite.git
 

 

# Nuevo versus Migración

Antes de arrancarlo, tenemos dos opciones: * Arrancar el servidor "vacío" sin repositorios y empezar desde cero * Arrancar el servidor usando respositorios de una instalación previa (migración)

## Instalación nueva

Dejo el directorio /Apps/data/git/repositories vacío y asigno a git:git como el propietario del mismo.

 
totobo ~ # mkdir -p /Apps/data/git
totobo ~ # cd /Apps/data/git
totobo git # chown -R git:git repositories
totobo git # chmod -R 750 repositories
 

Arranco la Aplicación (contenedor):

 
totobo ~ $ cd /Apps/docker/servicio-gitolite
totobo docker-gitolite $ **fig up**

A continuación clonamos gitolite-admin y empiezo a trabajar, añadir otros puestos de trabajo, sus claves, etc.

 
~ $ cd /home/luis/tmp
tmp $ git clone ssh://git@totobo.parchis.org:1600/gitolite-admin
 

 

## Migración

A la hora de migrar repositiorios desde otro servidor antiguo a mi nuevo Host (a su directorio persistente) el proceso también es muy sencillo: hago un backup del antiguo, lo recupero en el nuevo y al arrancar el contenedor se dará cuenta y respetará la estructura existente.

**Backup de repositorio existente**

Empezamos haciendo un backup del directorio de repositorios del servidor antiguo.

 
servidor_antiguo # cd /data/antiguo/dir/git
servidor_antiguo # tar cfz /tmp/backup_repos.tgz ./repositories
 

**Recuperar repositorio en el nuevo Host**

 
EN EL SERVIDOR ANTIGUO
servidor_antiguo # scp /tmp/backup_repos.tgz luis@totobo.parchis.org:/tmp

EN EL NUEVO Servidor:
totobo # cd /Apps/data/git
totobo # tar xfz /tmp/backup_repos.tgz
totobo # chown -R git:git repositories/
totobo # chmod -R g+rx repositories/
 

## Arrancar el contenedor

Creo y arranco el contenedor, detectará que el directorio repositories tiene repos existentes y actuará en consecuencia:

 
totobo ~ $ cd /Apps/docker/servicio-gitolite
totobo docker-gitolite $ fig up
 

## Comprobar que los repositorios están disponibles

Desde un cliente remoto que teníamos autorizado en el repositorio original

 
obelix:~ luis$ ssh -p 1600 git@totobo.parchis.org
hello ClaveLuisObelix, this is git@1279cc5fb4ed running gitolite3 v3.6.2-3-ge7752fc on git 1.9.1

 R W abaco-swift
 R W abaco-arte
 R W gitolite-admin
 R W espresso
 :
Connection to totobo.parchis.org closed.
obelix:~ luis$
 

 

# Acceso y consumo de los repositorios

{% include showImagen.html
    src="/assets/img/original/"
    caption="SourceTree"
    width="600px"
    %}

**Línea de comandos**

 
$ git clone ssh://git@totobo.parchis.org:1600/espresso
:
 

{% include showImagen.html
    src="/assets/img/original/st_0_o.jpg"
    caption="undefined"
    width="600px"
    %}

## Arranque durante el boot del Host

Para arrancar el contenedor durante el boot del equipo (recordar que el Host está basado en Gentoo con openrc) es tan sencillo como crear un script en el directorio /etc/init.d

#!/sbin/runscript
# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

depend() {
    need net
    need localmount
    need nfsmount
    after sshd
}

start() {
    ebegin "Arranando servicio: Gitolite"

        su luis -c "cd /Apps/docker/servicio-gitolite && /usr/local/bin/fig up -d --no-recreate"

        eend $?
}

stop() {
    ebegin "Parando servicio: Gitolite"

        su luis -c "cd /Apps/docker/servicio-gitolite &&  /usr/local/bin/fig stop"

    eend $?
}

status() {

        su luis -c "cd /Apps/docker/servicio-gitolite &&  /usr/local/bin/fig ps"

    eend $?
}

Por último programo el arranque automático en cada boot

 
# rc-update add servicio-gitolite default
 

Si usas systemd, te dejo un par de ejemplos de ficheros de servicios:

[Unit]
Description=Servicio GIT
After=syslog.target network.target auditd.service docker.service Apps.mount

[Service]
Type=oneshot
ExecStart=/bin/bash /Apps/docker/servicio-gitolite/start-fig.sh
ExecStop=/bin/bash /Apps/docker/servicio-gitolite/stop-fig.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target

[Unit]
Description=Apps
Wants=network.target rpc-statd.service
After=network.target rpc-statd.service

[Mount]
What=panoramix.parchis.org:/Apps
Where=/Apps
Type=nfs
StandardOutput=syslog
StandardError=syslog

{% include showImagen.html
    src="/assets/img/original/?p=172"
    caption="cómo configurar múltiples servicios en varios contenedores docker"
    width="600px"
    %}
