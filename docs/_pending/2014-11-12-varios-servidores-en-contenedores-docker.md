---
title: "Varios 'Servicios' en contenedores Docker"
date: "2014-11-12"
categories: apuntes
tags: docker multicontenedor
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/LuisPalacios)** y para entenderlos qué mejor que una imagen (click para ampliar"
    caption="Docker](https://hub.docker.com/u/luispa/)/[GitHub"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/docker1-1024x908.png"
    caption="docker"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/"
    caption="documentación"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/"
    caption="luispa/base-eskibana"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/"
    caption="luispa/base-gitolite"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/"
    caption="luispa/base-mysql"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/"
    caption="luispa/base-mysql"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/"
    caption="luispa/base-courierimap"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/"
    caption="luispa/base-postfixadmin"
    width="600px"
    %}

## Persistencia

Todos los contenedores se apoyan en una estructura persitente de datos en el Host:

 
/Apps/
     +--/data    <== Datos, repositorios, webs, ...
     |
     +--/docker  <== scripts, ficheros yml, ficheros para docker, etc... 
 

### Ejemplo

{% include showImagen.html
    src="/assets/img/original/)"
    caption="nginx"
    width="600px"
    %}

En la figura puedes ver a lo que me refiero, para resolverlo tendríamos un contenedor con "gitolite" y otros (tres en el gráfico) para dar los servicios "web"

{% include showImagen.html
    src="/assets/img/original/docker1-1024x848.png"
    caption="docker1"
    width="600px"
    %}

Espero que este apunte junto con los proyectos en el registry de Docker y en GitHub te sirvan de ayuda para tus própias instalaciones.
