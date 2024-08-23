---
title: "Dualboot Linux Windows"
date: "2024-07-25"
categories: desarrollo
tags: linux windows win11 ubuntu desarrollo dualboot
excerpt_separator: <!--more-->
---


![logo linux desarrollo](/assets/img/posts/logo-dual-boot.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

El dual boot normalmente se hace cuando tienes un Windows y luego instalas Linux. Mi caso es justo al revés, tengo un Ubuntu perfectamente instalado y funcionando, ocupando un disco de 4TB. Por circustancias necesito "añadir" Windows (11) y poder hacer dualboot, es decir, elegir durante el arranque qué Sistema Operativo voy a usar. Mi objetivo es dejarle 2TB a cada uno.

<br clear="left"/>
<!--more-->

## Primeros pasos

Mi equipo es un [Slimbook Kymera ATX](https://slimbook.com/kymera-atx) con:

- Ubuntu 24.04
- Kernel: 6.8.0-41-generic
- Motherboard: Gigabyte Z790 UD AX CPU: Intel Core i9-14900K
- BIOS Version: F11d
- Memory: 96GB (2x48GB) DDR5 6000MT/s / x2 Channel
- HD: 1 disco 4TB nvme + 2 discos 2TB SDD
- Sistema con UEFI y esquema de particionamiento GPT

Empezamos con Linux como único OS, en una única partición principal, en el disco de 4TB

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-01.png"
      caption="Gparted Linux"
      width="500px"
      %}

Recalco que todo lo que documento aquí se ha hecho con un sistema **con UEFI, Ubuntu y esquema de particionamiento GPT**. En teoría, los mismos pasos deberían ser aplicables a otras distribuciones.

## Requisitos

Esto es lo que vas a necesitar

- Una USB para Ubuntu Live (mín. 8GB)
- Una USB para Windows 11 (mín. 8GB)
- Que tu ordenador tenga UEFI y Ubuntu instalado
- Preferiblemente conexión a internet para instalar Windows
- Hacer un backup de tu linux (opcional pero recomendado)

Podríamos usar una única USB, pero es más cómodo tener dos. Si solo tienes una, primero creas la de Ubuntu, arrancas con ella, creas la partición para Windows y luego creas la de Windows y haces boot con ella para instalar Windows.

## Copia de seguridad

Si te equivocas trasteando con las particiones, perderás los datos. Tener una copia de seguridad en un disco externo es casi obligatorio. Que no se diga que no te he avisado.

Usa el sistema que quieras. En mi caso, cuando hago cosas de estas suelo usar [clonezilla](https://clonezilla.org/) y hago una copia completa del disco principal. En este caso es tan grande (4TB) que no tenía otro por ahí de ese tamaño, así que he salvado los archivos principales a un disco externo

## Crear USB con Ubuntu Live

El motivo de necesitarla es para modificar la partición de 4TB y estrecharla. Necesito liberar espacio para instalar Windows, pero no lo puedo hacer desde el mismo linux, con la partición ya montada. Por eso necesitas una Live USB, arrancaremos con ella para manipular las particiones.

Primer descargo la ISO de Ubuntu con la última versión desde [Download Ubuntu Desktop](https://ubuntu.com/download/desktop). Usé Desktop 24.04 LTS (6GB)

Ahora a quemarla en la USB. Puedes usar **Startup Disk Creator** (que viene con Ubuntu) o mejor [Balena Etcher](https://etcher.balena.io/#download-etcher) (aquí una [buena guía](https://itsfoss.com/install-etcher-linux/) por si no lo conoces). 

En mi caso me decanto por Balena Etcher, me bajé el fichero ***Etcher for Linux x64 (64-bit) (zip)***, lo descomprimí en un directorio, cambié permisos y ejecuté:

```shell
unzip ../Downloads/balenaEtcher-linux-x64-1.19.21.zip
cd balenaEtcher-linux-x64
sudo chown root:root chrome-sandbox
sudo chmod 4755 chrome-sandbox
./balena-etcher.sh
```

***Importante***, cuando inserto la USB me fijo en qué dispositivo queda; en mi caso fué `/dev/sdc`. Un comando muy útil para verlo. **Asegúrate de elegir el correcto, que sea la USB el destino de la copia** y no el disco principal u otro cualquiera...

```bash
# lsblk -p -o NAME,VENDOR,MODEL,SIZE,TYPE,SERIAL
NAME             VENDOR   MODEL                    SIZE TYPE SERIAL
/dev/loop0                                        10,1M loop
/dev/loop1                                        63,9M loop
/dev/loop2                                        74,2M loop
/dev/loop3                                        74,2M loop
/dev/loop4                                        13,9M loop
/dev/loop5                                        38,8M loop
/dev/sda         ATA      CT2000MX500SSD1          1,8T disk
└─/dev/sda1                                        1,8T part
/dev/sdb         ATA      CT2000MX500SSD1          1,8T disk
└─/dev/sdb1                                        1,8T part
/dev/sdc         Lexar    USB Flash Drive         58,2G disk  <-- !!! este
/dev/nvme0n1              Samsung SSD 990 PRO 4TB  3,6T disk
├─/dev/nvme0n1p1                                   300M part
└─/dev/nvme0n1p2                                   3,6T part
```

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-02.png"
      caption="Quemo la imagen Ubuntu"
      width="500px"
      %}

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-03.png"
      caption="Proceso de transferencia"
      width="200px"
      %}

Cuando termina salgo del programa, ya tenemos lista la USB de Ubuntu.

## Crear USB Live con Windows

Primero **descargo Windows 11**, desde el sitio oficial de [descargas](https://www.microsoft.com/software-download/windows11). Sección ISO, opción `Windows 11 (multi-edition ISO for x64 devices)`. Selecciono el Product language y empiezo la descarga (aprox. 6,3GB).

Para pasarla a la USB puedes hacerlo de forma sencilla si tienes ya un Windows ([aquí las instrucciones](https://support.microsoft.com/en-us/windows/create-installation-media-for-windows-99a58364-8c02-206f-aa6f-40c3b507420d)). En mi caso tengo un Linux así que me uso [Ventoy](https://www.ventoy.net/en/download.html) (una [guía](https://itsfoss.com/use-ventoy/) por si no lo conoces).

Con Ventoy vamos a crear una USB que hace boot, con dos particiones, una propia y otra para copiar el ISO de Windows. Empiezo descargando la última versión desde [Ventoy](https://www.ventoy.net/en/download.html), descomprimo el archivo `ventoy-1.0.99-linux.tar.gz` y ejecuto

```shell
cd Downloads
tar xfz ventoy-1.0.99-linux.tar.gz
cd ventoy-1.0.99
sudo ./VentoyWeb.sh
```

Me contecto con [http://127.0.0.1:24680](http://127.0.0.1:24680). desde `Option` deshabilito *Secure Boot* y selecciono `GPT` como tipo de partición.

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-04.png"
      caption="Quito Secure boot y selecciono GPT"
      width="500px"
      %}

Selecciona la ruta de almacenamiento en la que voy a instalar Ventoy y pulsa en Install. En mi caso, al conectar mi segunda USB lo hizo en `/dev/sdd`, lo selecciono, pulso Install y en breves segundos tenemos Ventoy en la USB.

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-05.png"
      caption="Instalo Ventoy"
      width="500px"
      %}

El proceso de instalación crea una segunda partición que es donde copiaremos la ISO. Uso el administrador de archivos para copiar la ISO descargada a la partición "***Ventoy***".

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-07.png"
      caption="Copio el ISO a la partición Ventoy"
      width="400px"
      %}

Fíjate cómo quedan las particiones de esta USB:

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-06.png"
      caption="Particiones de la USB con Ventoy y Windows"
      width="500px"
      %}

Expulso ambas particiones (`Ventoy, VTOYEFI`), ya hemos terminado, tenemos lista la segunda USB Windows. Si están insertadas puedes extraer las USBs.

## Liberar espacio en el disco

Primero toca hacer ***boot con la Live USB de Ubuntu***. Introduzco la USB de Ubuntu y reinicio el sistema, pulso la tecla que me permita entrar en el menú para elegir desde dónde hacer Boot (puede ser F2/F10/F12/ESC, depende tu BIOS).

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-08.png"
      caption="Selecciono la USB con Ubuntu"
      width="500px"
      %}

Seleccino la USB, pulso Enter y cuando Ubuntu muestra su menú de `grub` selecciono ***Try or Install Ubuntu***, el idioma, accesibilidad, teclado, conexión a internet, me salto actualizar el instalador y selecciono **Try Ubuntu**, pulso en Close.

Ya esoty en Ubuntu, ahora ejecuto la Aplicación Discos (Disks)

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-09.png"
      caption="Aplicación Discos"
      width="500px"
      %}

Selecciono mi disco duro principal y la partición donde está Linux, que es la que tengo que estrechar.

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-10.png"
      caption="Selecciono Disco y partición"
      width="500px"
      %}

Selecciono redimensionar / resize.

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-11.png"
      caption="Redimensionar partición"
      width="500px"
      %}

Introduzco en nuevo valor (la mitad del disco)

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-12.png"
      caption="Nuevo tamaño"
      width="500px"
      %}

Cuando termina (tarda un buen rato) queda como esperaba

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-13.png"
      caption="Resultado final"
      width="500px"
      %}

Rearranco el equipo, quito la USB de Ubuntu y compruebo que puede seguir haciendo boot en la partición redimensionada. Ya estoy listo para instalar Windows

## Instalar Windows

Le toca al "pesado" de Windows. Digo pesado porque verás que sigue siendo tremenda la instalación, tarda muchísimo, hace muchos reboots, es confusa. En fin, lo normal, no ha cambiado nada en 25 años.

Introduzco la USB con Ventoy + el ISO de Windows 11. Repito el proceso, rearranco el ordenador, pulso mi tecla (F12) para que la BIOS muestre las opciones de Boot, selecciono la USB (ahora de Ventoy/Windows).

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-14.jpg"
      caption="Arranque con Ventoy"
      width="500px"
      %}

Pulso Enter sobre la ISO, selecciono `Boot in normal mode`, veo el logo de Windows. Después de unos segundos, elijo el `idioma y el teclado`. La siguiente pantalla da la opción de iniciar la instalación. Hago clic en `Instalar ahora`.

En las siguientes pantallas, te pedirá la clave de licencia de Windows. Omito este paso porque lo activaré más tarde. Elijo la versión de Windows (en mi caso Windowss 11 Pro) y acepto la licencia de usuario final.

Selecciono la opción `Install Windows Custom`, automáticamente me ofrece instalar en la única partición que está vacía `Unalloated Space`, la selecciono y pulso en Next. A partir de aquí copia los ficheros y al terminar hace boot automáticamente.

Por suerte continúa instalando. Alguna vez que he hecho todo este proceso no seguía por donde debía, se enrocaba haciendo boot en la USB. Lo resolvía seleccionando el disco duro y la partición Windows vía la BIOS.

Con este ordenador hace bien el proceso, muestra un mensaje de `Getting ready`, vuelve a hacer reboot y continúa él solo. Al final acaba mostrando una ventana de Windows 11 donde selecciono el país, teclado, comprueba updates y hace un reboot de nuevo.

En el siguiente arranque me pide el nombre del dispositivo, vuelve a hacer reboot, pide que elija cómo voy a usar el dispositivo (personal o trabajo). Me gustaría saltarme esta parte pero es imposible (hay un truco pero no lo he seguido). Selecciono "Personal", hago login con mi cuenta de microsoft y continúo. Indico que no quiero hacer copia desde ningún otro equipo y lo configuro como nuevo.

Creo un PIN, parametrizo localización, buscar dispositivo, diagnósticos, inking, typing, tailored experiences, ads ID, etc... básicamente digo que no a todo. Me salto el temita del teléfono, le pido que no haga backups, que no importe nada de otro navegador y ya casi estamos.

Hace un útimo update que tarda lo suyo, tras varios minutos, reboots y trabajos misteriosos, acaba terminando y podemos entrar en Windows.

Poco que añadir, la instalación de Windows sigue siendo ineficiente y cansina. En fin, voy a terminar con el tema del dual boot. Aparco el Win11 y vuelvo al Linux.

En otro apunte explicaré cómo ***personalizarlo***, ***quitarle chorradas***, ***instalar drivers*** y ***dejarlo lo más decente posible*** (quitando todo lo que pueda).

## Vamos a por el dual boot

Ya tengo Windows instalado, pero debido a su endogamia, tiene la manía esconder mi Linux, de hecho a partir de ahora siempre hará boot con Windows a no ser que lo cambie. Podría dejarlo así y usar su boot manager, pero no me gusta, prefiero usar `grub`.

Voy a reconfigurar la BIOS y `grub` para que el sistema haga boot con ***Linux y Grub*** y que sea este último el que me permita elegir el Sistema Operativo con el que voy a trabajar.

Para conseguirlo es necesario ***entrar y hacerlo desde la BIOS***, porque como dije, Windows elimina toda opcion de volver a hacer boot desde Linux. Lo siguiente depende de tu sistema, explico aquí cómo lo hice en el mío. Reinicio el sistema y, pulso F12 (que es mi tecla de menú) que me permite entrar en el ***Setup de la BIOS***. Me voy a las opciones de boot, secuencia de arranque y cambio el orden de arranque, muevo Ubuntu hacia arriba en el orden.

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-15.jpg"
      caption="Posibilidad de cambiar el orden de Boot en la BIOS"
      width="650px"
      %}

Como véis en la captura, el Linux quedó segundo. Lo muevo a la primera posición, salvo los cambios y rearranco el equipo.

### Añadir Windows a Grub

Una vez en Linux y desde root confirmo que `os-prober` detecta la nueva partición "arrancable":

```shell
os-prober

/dev/nvme0n1p1@/EFI/Microsoft/Boot/bootmgfw.efi:Windows Boot Manager:Windows:efi
````

Edito `/etc/default/grub`, descomento la línea `GRUB_DISABLE_OS_PROBER=false`, de tal manera que `update-grub` use `os-prober` y añada una entrada de menú adicional al fichero `/etc/boot/grub/grub.cfg`

```shell
cat /etc/default/grub | grep PROBER

GRUB_DISABLE_OS_PROBER=false
```

Ejecuto `update-grub`.

```shell
update-grub

:
Sourcing file `/etc/default/grub'
Warning: os-prober will be executed to detect other bootable partitions.
:
Found Windows Boot Manager on /dev/nvme0n1p1@/EFI/Microsoft/Boot/bootmgfw.efi
:
```

Rearranco el equipo y veo el nuevo menú

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-16.jpg"
      caption="Diferentes opciones de arranque"
      width="650px"
      %}

Tenemos diferentes opciones pero prefiero limpiar este menú, arranco de nuevo con Linux para instalar un App llamada `Grub Customizer`

```shell
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y
apt install software-properties-common
add-apt-repository ppa:danielrichter2007/grub-customizer
apt-get update
apt install grub-customizer
```

Ejecuto `grub-customizer` desde mi usuario y el CLI; me pide la contraseña de root y me muestra todas las entradas que ví en el menú de arranque. Elimino las que no voy a usar (opciones avanzadas, memtest), cambio los títulos,

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-17.png"
      caption="Reconfiguro el menú de Grub"
      width="550px"
      %}

En `General Settings` establezco boot automático en `5 seg` y en `Appearance Settings` la resolución en `1920x1080`.

Después de Salvar, vuelvo a hacer boot para comprobar.

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-18.jpg"
      caption="Nuevo menú de arranque"
      width="650px"
      %}

Con esto llego al final, queda mucho por hacer, sobre todo la personalización del Windows 11, pero eso es otra historia.
