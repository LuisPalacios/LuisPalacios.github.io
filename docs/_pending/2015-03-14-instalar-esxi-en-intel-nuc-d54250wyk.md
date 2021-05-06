---
title: "Virtualización: Hypervisor ESXi"
date: "2015-03-14"
categories: virtualizacion
tags: virtualizacion
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/?p=725)) que hará de Host para ejecutar múltiples Guests o VM's (Máquinas Virtuales"
    caption="NUC D54250WYK"
    width="600px"
    %}

Parece fácil, usar un equipo barato, con buen rendimiento y poco consumo eléctrico, pero por desgracia me retrasó bastante la matriz de compatibilidad Hardware del ESXi. Por suerte tenemos internet y encontré la solución :-)

{% include showImagen.html
    src="/assets/img/original/D54250WYK-ESXi.png"
    caption="D54250WYK-ESXi"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/?p=2508), en vez de usar ESXi como Host consiste en usar directamente un equipo Linux como Host con la virtualización disponible en el Kernel, menos visual y atractivo pero más asequible y controlado (si conoces linux claro..."
    caption="estoy probando la opción KVM"
    width="600px"
    %}

Vamos al grano, estos son los pasos realizados para conseguir instalar VMWare ESXi en este equipo:

 

## Imagen ISO de instalación personalizada

El NUC D54250WYK soporta virutalización por Hardware e incluye una CPU (i5) con soporte de 64-bits, hasta ahí perfecto, es compatible con VMware ESXi. Pero... los drivers de la tarjeta LAN y de la tarjeta SATA, por desgracia, no están incluidos en la imagen base de ESXi. Una faena, según parece cuanto más evolucionan las versiones de ESXi menos soporte a Hardware no profesional, así que los "Laboratorios y Servidores Caseros" lo llevan no muy claro... Suerte que de momento, al menos para la versión ESXi 5.5 es posible crearse una imagen personalizada y meterle dentro los drivers que faltan, un proceso "relativamente" sencillo con el ESXi-Customizer (v-front.de). Los pasos que voy a realizar son:

- 1) Imagen (ISO) especial personalizada
    
{% include showImagen.html
    src="/assets/img/original/esxi-customizer.html"
    caption="ESXi-Customizer (ESXi-Customizer-v2.7.1.exe)"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/net-e1000e-2.3.2.x86_64.vib"
    caption="Intel Driver (net-e1000e-2.3.2.x86_64.vib)"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/sata-xahci-1.10-1.x86_64.vib"
    caption="SATA Controller (sata-xahci-1.10-1.x86_64.vib)"
    width="600px"
    %}
- 2) Copiar la imagen a una USB para hacer boot

 

## Imagen (ISO) especial personalizada

{% include showImagen.html
    src="/assets/img/original/"
    caption="este enlace"
    width="600px"
    %}

Ejecuto el ESXi-Customizer, selecciono la imagen original ESXi y el primer VIB (el e1000e por ejemplo), creo una nueva imagen y la renombro por ejemplo a ESXi-5.x-Custom-e1000e.iso. Vuelvo a ejecutar ESXi-Customizer, selecciona esta imagen recién creada y añado el driver SATA y renombro el resultado a "ESXi-5.x-Custom-e1000e-sata-xahci.iso".

{% include showImagen.html
    src="/assets/img/original/ESXi-Custom2.png"
    caption="ESXi-Custom1](https://www.luispa.com/wp-content/uploads/2015/03/ESXi-Custom1.png)](https://www.luispa.com/wp-content/uploads/2015/03/ESXi-Custom1.png)[![ESXi-Custom2"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/)"
    caption="unetbootin"
    width="600px"
    %}

## Boot con USB de Instalación

Arrancamos el el stick USB y pulsamos F10, en el menú de boot seleccionamos la opción:

- USB Boot Drive (no elegir la que pone UEFI)

Aparece un menú de UNetbootin, seleccionamos la opción:

- ESXi-5.5.0-2014...standard installer

Se ejecutará el ESXi installer, detectará nuestra CPU i5-4250U 1.30Ghz, los 16G de memoria y tras un período de carga de drivers y arranque de servicios mostrará una ventana de bienvenida, pulsamos Intro, aceptamos la licencia (con F11) y en ese momento escanea el Hardware.

Si todo ha ido bien (has personalizado correctamente la imagen ISO dos veces para instalar ambos drivers de LAN y SATA), pedirá que selecciones el disco y permitiendo que selecciones el SATA interno SSD. Lo selecciono, acepto que lo borre, specifico el teclado (Spanish) y pongo una contraseña a root.

Por último pulso F11 para que ejecute el proceso de instalación, borrará el disco y terminará tras unos minutos. Recuerda que debes hacerte con una licencia y activarla.  

## Boot con ESXi

La primera vez que hagamos boot veremos cómo se cargan los drivers y cómo nos indica que para administrar este Host tenemos que

- Descargar las herramientas de gestión de VMWare
- Conectar con:
    
    - http://nombre_del_sistema/
    - http://A.B.C.D/ (Dirección IP que haya recibido por DHCP)
    - http://[fe80::c...] Dirección IPv6 Estática.

Este apunte termina aquí, la administración de VMWare es otro asunto que está muy bien documentado por internet.

 

## Enlaces

Crédito a las fuentes que he utilizado para documentar este apunte técnico:

{% include showImagen.html
    src="/assets/img/original/"
    caption="VMware Homeserver – ESXi on 4th Gen Intel NUC"
    width="600px"
    %}
    
{% include showImagen.html
    src="/assets/img/original/"
    caption="Customized ISO with ESXi-Customizer by v-front.de"
    width="600px"
    %}
    
{% include showImagen.html
    src="/assets/img/original/<a href="
    caption="Installing vSphere ESXi on an D54250WYK"
    width="600px"
    %}
    
{% include showImagen.html
    src="/assets/img/original/5185"
    caption="Cómo añadir dos NICs al NUC"
    width="600px"
    %}
    

### Opciones para Gentoo

{% include showImagen.html
    src="/assets/img/original/?p=1803"
    caption="Gentoo VM en ESXi"
    width="600px"
    %}
