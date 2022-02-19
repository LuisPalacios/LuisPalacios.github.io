---
title: "Home Assistant @ Casa"
date: "2022-02-13"
categories: domótica
tags: linux homeassistant hassos hass
excerpt_separator: <!--more-->
---

![Logo Grafana](/assets/img/posts/logo-hass-casa.svg){: width="150px" style="float:left; padding-right:25px" } 

Home Assistant (HA) para la automatización del hogar, una software de código abierto que da prioridad al control local y a la privacidad. Impulsado por una comunidad mundial de aficionados al bricolaje, al háztelo tú mismo, el cacharreo y hacking.  Se puede instalar de múltiples formas. Yo he elegido la de **Home Assistant Operating System**, un **Appliance** que puede correr en múltiples plataformas, como la Raspberry Pi, un x86-64 con UEFI o incluso una máquina virtual sobre KVM (opción que documento en este apunte). 


<br clear="left"/>
<!--more-->

### Instalación de HA OS sobre KVM

Documento, de todas las [opciones de instalación disponibles](https://www.home-assistant.io/installation/), la de **Linux -> Home Assistant Operating System (VM)"**, básicamente un appliance con un sistema operativo linux mínimo y el Supervisor + Add-Ons de Home Assistant ya preinstalados. 

Internamente utiliza Docker como motor de contenedores, los diferentes módulos de los que está compuesto, como van a correr en contenedores. El sistema operativo de Home Assistant no está basado en una distribución Linux normal como Ubuntu. Está construido usando Buildroot y está optimizado para ejecutar Home Assistant.

WiP...

