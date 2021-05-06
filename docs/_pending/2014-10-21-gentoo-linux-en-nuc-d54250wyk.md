---
title: "Servidor Linux casero en NUC"
date: "2014-10-21"
categories: gentoo
tags: d54250wyk linux nuc
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/handbook-x86.xml"
    caption="Gentoo Linux AMD64 Handbook"
    width="600px"
    %}

Considerar este post como la "**Tabla de Contenidos**" ya que he separado todo la documentación en múltiples posts para hacerlos más sencillos. Importante, notar que utilizo sysvinit, openrc y baselayout2 (no uso systemd ni udev, sino el fork de eudev de Gentoo).

{% include showImagen.html
    src="/assets/img/original/intel-nuc-d54250wyk-4.jpg"
    caption="intel-nuc-d54250wyk-4"
    width="600px"
    %}

## Proceso de instalación Hardware y Software

{% include showImagen.html
    src="/assets/img/original/?p=740"
    caption="preparar la BIOS"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/?p=9"
    caption="USB de instalación"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/?p=759"
    caption="Iniciar la instalación"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/?p=774"
    caption="Particionar el disco SSD"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/?p=800) (chroot"
    caption="Stage 3, Portage y entrar en el nuevo entorno"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/?p=807"
    caption="configuración mínima"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/?p=831"
    caption="Instalación y configuración del Kernel"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/?p=861"
    caption="importantes antes de hacer boot"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/?p=861"
    caption="Terminar la instalación"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/?p=785"
    caption="Ficheros de configuración que utilizo"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/?p=665"
    caption="cómo he evolucionado a SMB2"
    width="600px"
    %}

Espero que esta guía sea de ayuda si necesitas montar Gento GNU/Linux en un Intel® NUC D54250WYK.

 

## Ejemplos de uso del servidor

Dejo aquí unos cuantos enlaces donde documento para qué tipo de cosas uso el servidor:

{% include showImagen.html
    src="/assets/img/original/?p=266"
    caption="Movistar Fusión Fibra + TV + VoIP con router Linux"
    width="600px"
    %}
    
{% include showImagen.html
    src="/assets/img/original/?p=172"
    caption="‘Servicios’ en contenedores Docker"
    width="600px"
    %}
    
{% include showImagen.html
    src="/assets/img/original/?p=1587"
    caption="descarga del EPG"
    width="600px"
    %}
