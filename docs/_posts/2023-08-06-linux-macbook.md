---
title: "Linux en MacBook Air 2015"
date: "2023-08-06"
categories: infraestructura
tags: linux mac macbook air efi dualboot
excerpt_separator: <!--more-->
---

![logo linux macbook](/assets/img/posts/logo-linux-macbook.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 


En este apunte describo cómo aprovechar un macbook air antiguo (2015) para instalarle Linux y extender su tiempo de vida. Con el tiempo estos mac's se convierten en equipos casi inútiles, con una velocidad pasmosa y memoria insuficiente. 

¿Porqué no aprovecharlos con Linux?. Un Macbook Air del 2015, con 8GB y 128GB de disco puede convertirse en un equipo muy útil. 

<br clear="left"/>
<!--more-->

### Instalación. 

He elegido Ubuntu Desktop para realizar la instalación. Estos son los pasos que he seguido: 

- Descargo la ISO de [Ubuntu 22.04.2 LTS Desktop](https://ubuntu.com/download/desktop)
- Flash del ISO en una USB con [balenaEtcher](https://etcher.balena.io) desde otro Mac.
- Introduzco la usb en el Macook Air y hago boot **manteniendo pulsada la tecla ALT**
- Hago doble clic sobre **EFI BOOT** 

{% include showImagen.html
    src="/assets/img/posts/2023-08-06-linux-macbook-01.jpg"
    caption="Selecciono la opción de EFI Boot"
    width="200px"
    %}

- Selecciono **Try or Install Ubuntu**

{% include showImagen.html
    src="/assets/img/posts/2023-08-06-linux-macbook-02.jpg"
    caption="Al cabo de unos segundos empieza a arrancar"
    width="400px"
    %}
{% include showImagen.html
    src="/assets/img/posts/2023-08-06-linux-macbook-03.jpg"
    caption="Selecciono la opción Instalar Ubuntu"
    width="400px"
    %}

- Selecciono **Spanish**
- Selecciono la opción de **instalación mínima** y también **Instalar programas de terceros**

{% include showImagen.html
    src="/assets/img/posts/2023-08-06-linux-macbook-04.png"
    caption="Instalación mínima"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/posts/2023-08-06-linux-macbook-05.png"
    caption="Opción de instalar programas de terceros"
    width="600px"
    %}
- Selecciono **borrar disco e instalar Ubuntu**
- Mi zona horaria. 
- Datos de mi usuario
- Inicia la instalación, tardará un rato.
- Al terminar, **quito la USB y reinicio el sistema**

Si no quieres GUI, a partir de aquí ya sólo te haría falta deshabilitarlo

- Cómo deshabilitar el GUI de Ubuntu
```console
$ sudo systemctl set-default multi-user
```
- Ya está, un ubuntu 100% operativo en un buen equipo, reinicio el equipo.
```console
$ reboot
```

