---
title: "Servidor Linux casero en NUC"
date: "2014-10-21"
categories: gentoo
tags: d54250wyk linux nuc
excerpt_separator: <!--more-->
---

En este artículo describo cómo instalar Gentoo GNU/Linux en un Intel® NUC D54250WYK. He optado por este kit después de investigar [cual sería mi próximo servidor casero](https://www.luispa.com/?p=725). Esta guía es un complemento al recomendadisimo manual oficial para este tipo de instalaciones: ![Gentoo Linux AMD64 Handbook](/assets/img/original/handbook-x86.xml){: width="730px" padding:10px }, un manual perfecto con mucho detalle.

Considerar este post como la "**Tabla de Contenidos**" ya que he separado todo la documentación en múltiples posts para hacerlos más sencillos. Importante, notar que utilizo sysvinit, openrc y baselayout2 (no uso systemd ni udev, sino el fork de eudev de Gentoo).

![intel-nuc-d54250wyk-4](/assets/img/original/intel-nuc-d54250wyk-4.jpg){: width="730px" padding:10px }

## Proceso de instalación Hardware y Software

- Lo primero es ![preparar la BIOS](/assets/img/original/?p=740){: width="730px" padding:10px }
- Crear ![USB de instalación](/assets/img/original/?p=9){: width="730px" padding:10px }
- ![Iniciar la instalación](/assets/img/original/?p=759){: width="730px" padding:10px } e información útil sobre el Hardware
- ![Particionar el disco SSD](/assets/img/original/?p=774){: width="730px" padding:10px }
![Stage 3, Portage y entrar en el nuevo entorno](/assets/img/original/?p=800) (chroot){: width="730px" padding:10px }
![configuración mínima](/assets/img/original/?p=807){: width="730px" padding:10px } del nuevo sistema
- ![Instalación y configuración del Kernel](/assets/img/original/?p=831){: width="730px" padding:10px }
- Últimos retoques ![importantes antes de hacer boot](/assets/img/original/?p=861){: width="730px" padding:10px } desde SSD
- ![Terminar la instalación](/assets/img/original/?p=861){: width="730px" padding:10px }

Si lo que quieres es ir rápido a ver ejemplos de configuración, te dejo aquí un enlace a los ![Ficheros de configuración que utilizo](/assets/img/original/?p=785){: width="730px" padding:10px }.

Dejo aquí enlaces adicionales, por ejemplo sobre cómo [arrancar con USB de emergencia](http://blog.luispa.com/index.php?controller=post&action=view&id_post=35) cuando la instalación se queda a medias o por algún error de configuración no consigues arrancar desde el SSD, otro para que sepas cómo [conectar un disco externo USB 3.0](http://blog.luispa.com/index.php?controller=post&action=view&id_post=41) como disco secundario y otro relativo a ![cómo he evolucionado a SMB2](/assets/img/original/?p=665){: width="730px" padding:10px }.

Espero que esta guía sea de ayuda si necesitas montar Gento GNU/Linux en un Intel® NUC D54250WYK.

 

## Ejemplos de uso del servidor

Dejo aquí unos cuantos enlaces donde documento para qué tipo de cosas uso el servidor:

1. ![Movistar Fusión Fibra + TV + VoIP con router Linux](/assets/img/original/?p=266){: width="730px" padding:10px }
    
2. Varios ![‘Servicios’ en contenedores Docker](/assets/img/original/?p=172){: width="730px" padding:10px }
    
3. Apoyo para mis [Media Centers](https://www.luispa.com/?p=1025), ![descarga del EPG](/assets/img/original/?p=1587){: width="730px" padding:10px }.
