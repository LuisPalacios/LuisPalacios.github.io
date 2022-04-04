---
title: "Alpine Linux personalizado"
date: "2022-04-02"
categories: servidor
tags: linux git servidor alpine custom personalizada imagen ISO
excerpt_separator: <!--more-->
---

![Logo gitea traefik docker](/assets/img/posts/logo-alpine.svg){: width="150px" style="float:left; padding-right:25px" } 

En este apunte describo como hacer imágines ISO personalizadas de Alpine Linux.  Alpine Linux es una distribución Linux independiente, no comercial y de propósito general, diseñada para usuarios avanzados que aprecian la seguridad, la simplicidad y la eficiencia de recursos. A mi me gusta mucho praa crear máquinas virtuales muy ligeras. 

<br clear="left"/>
<!--more-->

<br/>

## Introducción

Alpine Linux es una distribución muy pequeña, construida alrededor de [musl libc](https://www.musl-libc.org) y [busybox](https://busybox.net). Es más pequeño y eficiente en recursos que las distribuciones tradicionales de GNU/Linux. Un contenedor no requiere más de 8 MB y una instalación mínima en el disco requiere alrededor de 130 MB de almacenamiento. 

Utiliza su propio gestor de paquetes `apk`, el sistema de init [OpenRC](https://wiki.gentoo.org/wiki/Project:OpenRC), configuraciones basadas en scripts y un entorno Linux simple y claro.

En mi servidor Linux casero (basado en Ubuntu Server) tengo varias máquinas virtuales con Ubuntu pero también otras basadas en Alpine. Una de las ventajas de Alpine es que permite crear imágenes personalizadas. 

<br/>

## Imágenes personalizadas

Cuando necesitaba crear máquians virtuales basadas en Alpine me iba a su página de [descargas](https://alpinelinux.org/downloads/) seleccionaba el ISO desde VIRTUAL > *Slimmed down kernel. Optimized for virtual systems*, x86_64 (**solo 52MB**). Más adelante, con `virt-manager` me creaba la máquina virtual, la configuraba con `setup-alpine`, creaba mi usuario, parametrizaba SSH, editor e instalaba el software que fuese a correr encima. 

Tras repetir esto un par de veces descubrí una forma mucho más óptima de trabajar. Consiste en crearme mis propias [imágenes ISO personalizadas](https://wiki.alpinelinux.org/wiki/How_to_make_a_custom_ISO_image_with_mkimage) con `mkimage` y automatizar al máximo todo el proceso. 


| De hecho mi objetivo principal es poder **crear de forma rápida máquinas virtuales con Alpine y Docker para poder ejecutar en ellas cualquier contenedor**. Una forma rápida de tener una plataforma ligera para ejecutar servicios |

<br/>

### Crear una imagen personalizada

Resulta escandalosamente fácil crear un ISO personalizado de Alpine Linux. Lo mejor es hacerlo todo desde el propio Alpine, así que voy a usar un contenedor Docker basado en Alpine para simplificar todo el proceso. 

- Hay miles de ejemplos y tutoriales sobre cómo prepararte un host con Docker. En mi caso uso una máuqina virtual, que documenté en el apunte [Alpine para ejecutar contenedores]({% post_url 2022-03-20-alpine-docker %}). Mi VM se llama `docker.parchis.org`

<br/>

Proceso:

- Directorio de trabajo
```console
docker:~$ mkdir base-alpinedocker
docker:~$ cd base-alpinedocker/
docker:~/base-alpinedocker$ nano Dockerfile
```
- Creo un contenedor Docker basado en Alpine Linux: `Dockerfile`
```console
# Desde alpine Linux
#
ARG VERSION=${VERSION:-"3.15"}
FROM alpine:$VERSION
ARG VERSION

# Maintainer
MAINTAINER Luis Palacios <luis@luispa.com>

# Añado los repos
RUN \
   echo "https://dl-cdn.alpinelinux.org/alpine/v${VERSION}/main" > /etc/apk/repositories && \
   echo "https://dl-cdn.alpinelinux.org/alpine/v${VERSION}/community" >> /etc/apk/repositories

# Actualizo Alpine y los paquetes base
RUN apk --no-cache --update-cache --available upgrade

# Instalo un par de cosillas
RUN \
    apk add --no-cache --update-cache \
      bash \
      curl \
      ca-certificates \
      libgcc \
      lksctp-tools \
      pcre \
      zlib-dev

#RUN echo $VERSION > image_version
```
- Fabrico una imagen en local para crear el contenedor
```console
docker:~/base-alpinedocker$ docker build -t luispa/base-alpinedocker ./
```
- Creo el contenedor y me contecto con él
```console
docker:~/base-alpinedocker$ docker build -t luispa/base-alpinedocker --build-arg VERSION=3.15 ./
```

--

Referencias

- https://lemoncode.net/lemoncode-blog/2020/2/12/hola-docker-ci-cd-github-actions
- https://github.com/Mexit/AlpDock
- https://github.com/bitwalker/alpine-erlang/blob/master/Dockerfile
- https://github.com/bitwalker/alpine-erlang/blob/master/Dockerfile
- https://gitlab.alpinelinux.org/alpine/aports
- https://wiki.alpinelinux.org/wiki/How_to_make_a_custom_ISO_image_with_mkimage
- https://github.com/Mexit/AlpDock/blob/master/.github/workflows/build_iso.yml
- https://eyedeekay.github.io/kloster/
- https://hub.docker.com/r/bashell/alpine-bash/dockerfile/
- https://github.com/tiredofit/docker-alpine/blob/master/Dockerfile
