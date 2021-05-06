---
title: "Gentoo en NUC: BIOS"
date: "2014-10-22"
categories: gentoo
tags: bios linux
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/?p=7"
    caption="instalación Gentoo GNU/Linux en un Intel® NUC D54250WYK"
    width="600px"
    %}

## La BIOS

{% include showImagen.html
    src="/assets/img/original/cs-033935.htm"
    caption="cambios recomendados en la BIOS"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/Detail_Desc.aspx?DwnldID=24326&lang=spa&ProdId=3744"
    caption="BIOS que yo instalé"
    width="600px"
    %}

Descargo el fichero wy0030.bio, me hago con un USB 2.0 de 4GB. En mi iMac inserto el USB y desde DiskUtility -> Formato MS-DOS FAT -> Nombre: "FAT32". Copio el fichero wy0030.bio al USB, lo inserto en el NUC, arranco y desde su menú principal de "Visual BIOS" realizo la actualización.

- F2 —> Entrar en el menú de BIOS
- F10 —> Menú de selección de dispositivo de arranque

Una vez actualizado, vuelvo a arrancar y entro de nuevo para dejar esta configuración de BIOS, que será la que emplearé durante la instalación de Gentoo

- ADVANCED —> Main-> Poner Hora y Día
- ADVANCED —> Devices —> USB: USB Legacy (ACTIVO)
- ADVANCED —> Devices —> SATA: Chipset SATA (activo) y Mode: AHCI
- ADVANCED —> Devices —> VIDEO: IGD Minimum Memory: 512MB
- ADVANCED —> Devices —> Onboard Devices -> Num Lock (INACTIVO)
- ADVANCED —> Boot —> Boot Priority -> UEFI Boot (ACTIVO) + LEGACY BOOT (ACTIVO)
- ADVANCED —> Boot —> Boot Configuration -> Fast Boot (INACTIVO)
- ADVANCED —> Boot —> Boot Configuration -> Boot Devices: USB,Optical,Network (ACTIVO)

{% include showImagen.html
    src="/assets/img/original/visual2_3_o.jpg"
    caption="visual2_3_o"
    width="600px"
    %}

Nota: Podrás acelerar el arranque una vez que termines la instalación (hacerlo solo cuando ya tengas todo instalado en el SSD y el arranque te funcione sin problemas). Consiste en usar una opción muy chula de la BIOS llamada "Fast Boot", que desactiva (ignora) cualquier dispositivo de arranque (por ejemplo USBs) y solo arranca desde el SSD interno.

- ADVANCED—> Boot —> Boot Configuration -> Fast Boot (ACTIVO)

**Nota**: Si alguna vez activas "Fast Boot" ten en cuenta que no podrás arrancar el equipo desde una USB y además no podrás entrar en la BIOS de forma sencilla, dado que el F2 no funciona. **Para salir de esa situación, el truco** consiste en "**desenchufar**" el cable de potencia, volver a enchufarlo, arrancar el NUC y pulsar repetidamente F2 hasta conseguir entrar en la BIOS (ahí ya podrás desactivar Fast Boot)

Entro en la configuración de la tarjeta Ethernet y me apunto su device ID y dirección MAC (así puedo asignarle una IP fija desde mi dhcp server)

 

{% include showImagen.html
    src="/assets/img/original/?p=9"
    caption="Crear USB de instalación"
    width="600px"
    %}
