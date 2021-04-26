---
title: "Gentoo en NUC: BIOS"
date: "2014-10-22"
categories: 
  - "gentoo"
tags: 
  - "bios"
  - "linux"
---

Nota: Este post pertenece a una "colección", así que te recomiendo que empieces por la [instalación Gentoo GNU/Linux en un Intel® NUC D54250WYK](https://www.luispa.com/?p=7), si no lo has hecho ya. En este artículo en concreto describo cómo preparar la BIOS del equipo

## La BIOS

En el documento de [Compatibilidad del NUC con Linux](http://www.intel.com/support/sp/motherboards/desktop/sb/cs-034779.htm)  vienen explicados algunos [cambios recomendados en la BIOS](http://www.intel.com/support/sp/motherboards/desktop/sb/cs-033935.htm) si vas a instalar GNU/Linux. Notar que en mi caso, que voy a usar UEFI y tabla de particiones GPT, he optado por una opción diferente que describo a continuación.

Lo primero que recomiendo es actualizar la BIOS a su última versión (a fecha Oct/2014 era 0030), en este enlace tienes las [descargas para el NUC D54250WYK](https://downloadcenter.intel.com/SearchResult.aspx?lang=spa&ProductID=3744&ProdId=3744) y esta es la [BIOS que yo instalé](https://downloadcenter.intel.com/Detail_Desc.aspx?DwnldID=24326&lang=spa&ProdId=3744).

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

[![visual2_3_o](https://www.luispa.com/wp-content/uploads/2014/12/visual2_3_o.jpg)](https://www.luispa.com/wp-content/uploads/2014/12/visual2_3_o.jpg)

Nota: Podrás acelerar el arranque una vez que termines la instalación (hacerlo solo cuando ya tengas todo instalado en el SSD y el arranque te funcione sin problemas). Consiste en usar una opción muy chula de la BIOS llamada "Fast Boot", que desactiva (ignora) cualquier dispositivo de arranque (por ejemplo USBs) y solo arranca desde el SSD interno.

- ADVANCED—> Boot —> Boot Configuration -> Fast Boot (ACTIVO)

**Nota**: Si alguna vez activas "Fast Boot" ten en cuenta que no podrás arrancar el equipo desde una USB y además no podrás entrar en la BIOS de forma sencilla, dado que el F2 no funciona. **Para salir de esa situación, el truco** consiste en "**desenchufar**" el cable de potencia, volver a enchufarlo, arrancar el NUC y pulsar repetidamente F2 hasta conseguir entrar en la BIOS (ahí ya podrás desactivar Fast Boot)

Entro en la configuración de la tarjeta Ethernet y me apunto su device ID y dirección MAC (así puedo asignarle una IP fija desde mi dhcp server)

 

Siguiente paso: [Crear USB de instalación](https://www.luispa.com/?p=9)
