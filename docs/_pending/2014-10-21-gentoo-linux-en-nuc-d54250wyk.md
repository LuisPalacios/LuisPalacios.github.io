---
title: "Servidor Linux casero en NUC"
date: "2014-10-21"
categories: 
  - "gentoo"
tags: 
  - "d54250wyk"
  - "linux"
  - "nuc"
---

En este artículo describo cómo instalar Gentoo GNU/Linux en un Intel® NUC D54250WYK. He optado por este kit después de investigar [cual sería mi próximo servidor casero](https://www.luispa.com/?p=725). Esta guía es un complemento al recomendadisimo manual oficial para este tipo de instalaciones: [Gentoo Linux AMD64 Handbook](https://www.gentoo.org/doc/es/handbook/handbook-x86.xml), un manual perfecto con mucho detalle.

Considerar este post como la "**Tabla de Contenidos**" ya que he separado todo la documentación en múltiples posts para hacerlos más sencillos. Importante, notar que utilizo sysvinit, openrc y baselayout2 (no uso systemd ni udev, sino el fork de eudev de Gentoo).

[![intel-nuc-d54250wyk-4](https://www.luispa.com/wp-content/uploads/2014/12/intel-nuc-d54250wyk-4.jpg)](https://www.luispa.com/wp-content/uploads/2014/12/intel-nuc-d54250wyk-4.jpg)

## Proceso de instalación Hardware y Software

- Lo primero es [preparar la BIOS](https://www.luispa.com/?p=740)
- Crear [USB de instalación](https://www.luispa.com/?p=9)
- [Iniciar la instalación](https://www.luispa.com/?p=759) e información útil sobre el Hardware
- [Particionar el disco SSD](https://www.luispa.com/?p=774)
- Descargar [Stage 3, Portage y entrar en el nuevo entorno](https://www.luispa.com/?p=800) (chroot)
- Iniciar la [configuración mínima](https://www.luispa.com/?p=807) del nuevo sistema
- [Instalación y configuración del Kernel](https://www.luispa.com/?p=831)
- Últimos retoques [importantes antes de hacer boot](https://www.luispa.com/?p=861) desde SSD
- [Terminar la instalación](https://www.luispa.com/?p=861)

Si lo que quieres es ir rápido a ver ejemplos de configuración, te dejo aquí un enlace a los [Ficheros de configuración que utilizo](https://www.luispa.com/?p=785).

Dejo aquí enlaces adicionales, por ejemplo sobre cómo [arrancar con USB de emergencia](http://blog.luispa.com/index.php?controller=post&action=view&id_post=35) cuando la instalación se queda a medias o por algún error de configuración no consigues arrancar desde el SSD, otro para que sepas cómo [conectar un disco externo USB 3.0](http://blog.luispa.com/index.php?controller=post&action=view&id_post=41) como disco secundario y otro relativo a [cómo he evolucionado a SMB2](https://www.luispa.com/?p=665).

Espero que esta guía sea de ayuda si necesitas montar Gento GNU/Linux en un Intel® NUC D54250WYK.

 

## Ejemplos de uso del servidor

Dejo aquí unos cuantos enlaces donde documento para qué tipo de cosas uso el servidor:

1. [Movistar Fusión Fibra + TV + VoIP con router Linux](https://www.luispa.com/?p=266)
    
2. Varios [‘Servicios’ en contenedores Docker](https://www.luispa.com/?p=172)
    
3. Apoyo para mis [Media Centers](https://www.luispa.com/?p=1025), [descarga del EPG](https://www.luispa.com/?p=1587).
