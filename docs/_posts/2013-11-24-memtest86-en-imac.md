---
title: "MemTest86 en iMac"
date: "2013-11-24"
categories: herramientas
tags: macosx memtest86 boot
excerpt_separator: <!--more-->
---


![Logo memtest](/assets/img/posts/logo-memtest.jpg){: width="150px" style="float:left; padding-right:25px" } 

Para mi nuevo iMac 27" (finales del 2013) compré una ampliación de 32GB de memoria. Apple soporta que instales memoria de terceros, compré la ampliación en Crucial.com y una de las cosas que quería hacer era probar la memoria en profundidad.

<br clear="left"/>
<!--more-->

No es que sea de avisos, pero no está de más: Esto que cuento aquí puede hacer que te cargues el proceso de arranque de tu Mac, así que mejor que no lo hagas si no eres un Hacker avanzado.

## Introducción

Ahí es donde entra MemTest86, un programa fantástico para probar las memorias. Lo ideal es ejecutarlo de forma nativa inmediatamente después de hacer boot, sin entrar en el sistema operativo, pero eso no es tan fácil en un Mac. Veamos cómo hacerlo sin necesidad de hacer boot desde DVD o USB. El proceso es relativamente sencillo, consiste en instalar un Boot Manager (rEFInd Boot Manager) distinto al que trae el Mac, añadir entre sus opciones MemTest86 (versión EFI) y durante el siguiente boot seleccionarlo para pasar las pruebas de memoria, ¿fácil no?

Ah!, hay una alternativa a todo esto, consiste en ejecutar memtest desde MacOSX, aunque no es tan "nativo". El programa se llama `Rember`, un GUI que utiliza memtest86 desde el sistema operativo.

## Instalación de rEFInd

Vamos a por la opción "arriesgada :-)"... Descarga rEFInd, en concreto utilicé el "binary zip file", que es compatible con el iMac 27" (late 2013, también probado en mid 2011). Una vez que lo tengas bucea en el subdirectorio `refind-bin-0.7.5`

{% include showImagen.html 
      src="/assets/img/original/refind1.png" 
      caption="Directorio desde donde instalaré rEFInd." 
      width="600px"
      %}

Abre el Terminal.app y ejecuta "install.sh"  (OJO!! que va a "tocar" el firmware de tu Mac, aquí vuelvo a avisar, no me responsabilizo del posible desastre. Si no sabes de qué va todo esto ni se te ocurra seguir...)

```bash
asterix:~ luis$ cd Downloads/refind-bin-0.7.5/
asterix:refind-bin-0.7.5 luis$ ./install.sh
Not running as root; attempting to elevate privileges via sudo....
Password:
Installing rEFInd on OS X....
Installing rEFInd to the partition mounted at //
Copied rEFInd binary files
Copying sample configuration file as refind.conf; edit this file to configure
rEFInd.

WARNING: If you have an Advanced Format disk, *DO NOT* attempt to check the
bless status with 'bless --info', since this is known to cause disk corruption
on some systems!!

Installation has completed successfully.
```

Se instala en el directorio /EFI de tu equipo y "toca" el firmware, como avisé :-). La próxima vez que arranques lo harás con el nuevo Boot Manager rEFInd, pero espera, antes de arrancar tienes que instalar MemTest86...

{% include showImagen.html 
      src="/assets/img/original/refind2.png" 
      caption="Ubicación de la instalación rEFInd." 
      width="600px"
      %}
      

## Instalación de MemTest86

El siguiente paso consiste en añadir MemTest86 al directorio /EFI/tools. Lo primero es descargar la version "5.0 UEFI", en concreto la imagen para USB para Linux (Image for creating boot-able USB Drive). Ignora lo de USB, lo que queremos es ese paquete para sacar unos pocos ficheros, en concreto la versión EFI del programa MemTest86 de 64 bits

Así que después de descargar, accede usando Finder y deberías ver el fichero "memtest86-usb.tar". Haz doble click sobre él, busca la imagen "memtest86-pro-usb.img", vuelve a hacer doble clic sobre ella,  se montará un disco llamado "Untitled" y dentro encontrarás un subdirectorio llamado "EFI", y si sigues navegando llegarás  a donde nos interesa...

{% include showImagen.html 
      src="/assets/img/original/refind3.png" 
      caption="Subdirectorio EFI." 
      width="600px"
      %}

Crea el directorio /EFI/tools/memtest86 y copia desde la imagen el contenido del directorio EFI/BOOT. Ojo!!! no copies el fichero BOOTIA32.efi, dado que no hace falta, de hecho "NO" debe copiarse.

{% include showImagen.html 
      src="/assets/img/original/refind4.png" 
      caption="Copia del directorio EFI/BOOT" 
      width="600px"
      %}


Ahora solo tienes que reiniciar el Mac, justo después del sonido de campana del arranque verás la pantalla de rEFInd, desde la cual podrás ejecutar MemTest86

{% include showImagen.html 
      src="/assets/img/original/refind5.png" 
      caption="Vistazo a la nueva pantalla de BOOT" 
      width="600px"
      %}

Este proceso lo he probado con éxito tanto en un iMac 27" mid 2011 como un iMac 27" late 2013, ambos con Mavericks y ha funcionado correctamente. El objetivo no es tener múltiples sistemas operativos en el Mac (que rEFInd permite), sino simplemente hacer pruebas en profundidad de la memoria.

## Eliminar rEFInd

Si quieres quitar rEFInd de tu Mac, tan simple como entrar en Manzana->Preferencias del Sistema-Disco de Arranque. Selecciona (aunque ya lo está) el Disco duro y pulsa en "Reiniciar". Después de comprobar que arranca correctamente ya puedes borrar el directorio /EFI de tu disco duro.


{% include showImagen.html 
      src="/assets/img/original/refind6.png" 
      caption="Opción para eliminar rEFInd" 
      width="600px"
      %}
