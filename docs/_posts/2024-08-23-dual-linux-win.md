---
title: "Dualboot Linux Windows"
date: "2024-08-23"
categories: administración
tags: linux windows win11 ubuntu desarrollo dualboot
excerpt_separator: <!--more-->
---


![logo linux desarrollo](/assets/img/posts/logo-dual-boot.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

El dual boot normalmente se hace cuando tienes Windows y luego añades Linux. Mi caso es justo al revés, tengo Ubuntu perfectamente instalado y funcionando en un disco de 4TB. Por circustancias necesito "añadir" Windows (11) y poder hacer dualboot, elegir durante el arranque qué Sistema Operativo usar. En este apunte describo todo el proceso, cómo he redimensionado el disco dejándole 2TB a cada uno y activando la opción de dualboot.

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

## Requisitos

Voy a necesitar

- USB para Ubuntu Live (mín. 8GB)
- USB para Windows 11 (mín. 8GB)
- Importante UEFI y GPT (y en este ejemplo Ubuntu instalado)
- Conexión a internet para instalar Windows (preferible)
- Backup de Linux (opcional pero recomendado)

Podría usar una única USB, pero es más cómodo tener dos. Si solo tienes una, primero creas la Live de Ubuntu, arrancas con ella, preparas las particiones, rearrancas con Linux, creas la USB de Windows y haces boot con ella para instalarlo.

## Copia de seguridad

Si te equivocas trasteando con las particiones, perderás los datos. Tener una copia de seguridad en un disco externo es casi obligatorio. Que no se diga que no te he avisado.

Usa el sistema que quieras. En mi caso, cuando hago cosas de estas suelo usar [clonezilla](https://clonezilla.org/) y hago una copia completa del disco principal. En este caso es tan grande (4TB) que no tenía otro por ahí de ese tamaño, así que he salvado los archivos principales a un disco externo

## Crear USB con Ubuntu Live

Solo la necesito para manipular estrechar la partición de Linux y dejar sitio. Como no se puedo hacer desde el mismo linux, porque está montada, hace falta hacer boot con una Live USB. Primer descargo la ISO de Ubuntu desde [Download Ubuntu Desktop](https://ubuntu.com/download/desktop). Usé Desktop 24.04 LTS (6GB)

Para quemar esa imagen en una USB puedo usar **Startup Disk Creator** (que viene con Ubuntu), pero prefiero [Balena Etcher](https://etcher.balena.io/#download-etcher) (aquí una [guía](https://itsfoss.com/install-etcher-linux/)). En mi caso me decanto por Balena Etcher, me bajé ***Etcher for Linux x64 (64-bit) (zip)***, lo descomprimí en un directorio, cambié permisos y ejecuté:

```shell
unzip ../Downloads/balenaEtcher-linux-x64-1.19.21.zip
cd balenaEtcher-linux-x64
sudo chown root:root chrome-sandbox
sudo chmod 4755 chrome-sandbox
./balena-etcher.sh
```

***Importante***, cuando inserto la USB me fijo en qué dispositivo queda; en mi caso `/dev/sdc`.

```shell
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

Insisto, **asegúrate de elegir el dispositivo destino correcto, que sea la USB y no el disco principal u otro cualquiera**.

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

Cuando termina ya tenemos lista la USB de Ubuntu.

## Crear USB Live con Windows

Primero **descargo Windows 11**, desde el sitio oficial de [descargas](https://www.microsoft.com/software-download/windows11). Sección ISO, opción `Windows 11 (multi-edition ISO for x64 devices)`. Selecciono el Product language y empiezo la descarga (aprox. 6,3GB).

Para pasarla a una USB es sencillo si tienes ya un Windows ([aquí las instrucciones](https://support.microsoft.com/en-us/windows/create-installation-media-for-windows-99a58364-8c02-206f-aa6f-40c3b507420d)). En mi caso lo hago desde mi linux con [Ventoy](https://www.ventoy.net/en/download.html) (una [guía](https://itsfoss.com/use-ventoy/)).

Ventoy preparar la USB, la hace bootable con dos particiones. En una de ellas copiaremos el ISO de Windows. Descargo la última versión desde [Ventoy](https://www.ventoy.net/en/download.html), descomprimo y ejecuto.

```shell
cd Downloads
tar xfz ventoy-1.0.99-linux.tar.gz
cd ventoy-1.0.99
sudo ./VentoyWeb.sh
```

Desde un browser me contecto con [http://127.0.0.1:24680](http://127.0.0.1:24680). En `Option` deshabilito *Secure Boot* y selecciono `GPT` como tipo de partición.

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-04.png"
      caption="Quito Secure boot y selecciono GPT"
      width="500px"
      %}

Selecciono la ruta de almacenamiento en la que voy a instalar Ventoy (en mi caso ahora es `/dev/sdd`) y pulso Install.

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-05.png"
      caption="Instalo Ventoy"
      width="500px"
      %}

Copio el ISO de Windows a la segunda partición "***Ventoy***".

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-07.png"
      caption="Copio el ISO a la partición Ventoy"
      width="400px"
      %}

Así queda la USB

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-06.png"
      caption="Particiones de la USB con Ventoy y Windows"
      width="500px"
      %}

Expulso ambas particiones (`Ventoy, VTOYEFI`), ya hemos terminado, tenemos lista la segunda USB Windows.

## Liberar espacio en el disco

Introduzco la ***USB Live de ubuntu y hago boot***. Tengo que pedirle a la BIOS que me muesre la opción de hacer boot desde ella. En todos los ordenadores se hace pulsando una tecla durante el boot, puede ser F2/F10/F12/ESC, depende tu BIOS.

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-08.png"
      caption="Selecciono la USB con Ubuntu"
      width="500px"
      %}

Seleccino la USB, pulso Enter. Aparece un menú, selecciono ***Try or Install Ubuntu***, pongo el idioma, accesibilidad, teclado, conexión a internet, me salto actualizar el instalador y selecciono **Try Ubuntu**, pulso en Close. Una vez que tengo Ubuntu arrancado, ejecuto la Aplicación Discos (Disks)

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

Ahora toca instalar Windows, ten paciencia, tarda bastante, con varios reboots, por lo que veo no ha cambiado nada en 25 años. Introduzco la USB con Ventoy + el ISO de Windows 11. Repito el proceso, rearranco el ordenador, pulso mi tecla para que la BIOS muestre las opciones de Boot, selecciono la USB.

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-14.jpg"
      caption="Arranque con Ventoy"
      width="500px"
      %}

Pulso Enter sobre la ISO, selecciono `Boot in normal mode`, veo el logo de Windows. Elijo el `idioma y el teclado`, `Instalar ahora`, en la clave de licencia de Windows omito el paso, lo activaré luego. Elijo la versión de Windows (en mi caso Windowss 11 Pro), acepto la licencia, selecciono `Install Windows Custom`, me ofrece instalar en la única partición que está vacía `Unalloated Space`. A partir de aquí copia los ficheros y al terminar hace boot automáticamente. Por suerte continúa instalando. Alguna vez que he hecho todo este proceso no seguía por donde debía, se enrocaba haciendo boot en la USB. Lo resolvía seleccionando el disco duro y la partición Windows vía BIOS.

Con este ordenador va todo bien, muestra `Getting ready`, otro reboot, acaba pidiendo país, teclado, comprueba updates y hace un reboot de nuevo. Pide que le ponga un mote al ordenador, vuelve a hacer reboot, pide cómo voy a usar el dispositivo (personal o trabajo). Me gustaría saltarme esta parte pero es imposible (hay un truco pero no lo he seguido). Selecciono "Personal", hago login con mi cuenta de microsoft y continúo. Indico que no quiero hacer copia desde ningún otro equipo y lo configuro como nuevo. Creo un PIN, localización, buscar dispositivo, diagnósticos, inking, typing, tailored experiences, ads ID, etc... básicamente digo que no a todo. Me salto lo del teléfono, pido que no haga backups, que no importe nada de otro navegador. Hace un útimo update que tarda lo suyo, tras varios minutos, reboots y trabajos misteriosos, acaba terminando y podemos entrar en Windows.

En fin, voy a terminar con el tema del dual boot. Aparco el Win11 y vuelvo al Linux.

Por cierto, en el apunte [Un Windows decente]({% post_url 2024-08-24-win-decente %}) explico como termino de instalar y configurar este Win11, cómo ***personalizar***, ***quitar anuncios***, ***instalar drivers*** y ***dejarlo lo más decente posible*** (quitando todo lo que sobra).

## Vamos a por el dual boot

Ya tengo Windows instalado, pero debido a su endogamia, esconde al Linux. En la BIOS ha quedado marcado que haga boot desde la partición de Windows y Linux pasa a segundo lugar. Podría dejarlo así y usar su boot manager, pero no me gusta. Voy a reconfigurar la BIOS para que haga boot con ***Linux*** y configuraré ***grub*** para que me muestre un menú.

Reinicio el sistema entro en ***Setup de la BIOS***, cambio la secuencia de arranque, así es como lo tenía, subí Ubuntu hacia arriba en el orden.

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-15.jpg"
      caption="Posibilidad de cambiar el orden de Boot en la BIOS"
      width="650px"
      %}

### Añadir Windows a Grub

Una vez en Linux y desde root voy a parametrizr `grub`. Primero confirmo que `os-prober` detecta la nueva partición "arrancable":

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

Ya puedo volver a dejar en `/etc/default/grub`, la línea comentada `#GRUB_DISABLE_OS_PROBER=false`

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

### Personalizo Grub

Grub permite aplicar temas y personalizar la apariencia de su gestor de arranque. Si desea un menú de arranque que sea visualmente atractivo y también fácil de navegar, puedes personalizar con temasa. Una buena fuemte es [Gnome-Look.org](https://www.gnome-look.org/browse?cat=109&ord=rating). En mi ejemplo descargué `Stylish-1080p.tar.xz` desde [aquí](https://www.gnome-look.org/p/1009237).

```shell
mkdir -p /boot/grub/themes
cd /boot/grub/themes
tar xvf Stylish-1080p.tar.xz
```

Modifico bajo `/etc/default/grub.d`, elimino el que venía con mi sistema y pongo el nuevo

```config
rm /etc/default/grub.d/slimbook.cfg

cat /etc/default/grub.d/tema-grub.cfg

GRUB_THEME="/boot/grub/themes/Stylish/theme.txt"
```

Así es como queda mi fichero `/etc/default/grub`

```conf
GRUB_DEFAULT="0"
GRUB_TIMEOUT="5"
GRUB_DISTRIBUTOR="Slimbook-OS"
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
GRUB_GFXMODE="1920x1080x32"
GRUB_GFXPAYLOAD_LINUX="1920x1080x32"
GRUB_INIT_TUNE="1000 334 1 334 1 0 1 334 1 0 1 261 1 334 1 0 1 392 2 0 4 196 2"
GRUB_ENABLE_BLSCFG="false"
```

Ejecuto

```shell
update-grub
```

Listo, ya tengo dualboot. Ahora ya solo me queda configurar y dejar el Windows 11 [lo más decente]({% post_url 2024-08-24-win-decente %}) posible. Sin anuncios, ni florituras.
