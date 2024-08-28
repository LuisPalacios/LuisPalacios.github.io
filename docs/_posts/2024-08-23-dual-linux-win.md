---
title: "Dualboot Linux Windows"
date: "2024-08-23"
categories: administración
tags: linux windows win11 ubuntu desarrollo dualboot
excerpt_separator: <!--more-->
---


![logo linux desarrollo](/assets/img/posts/logo-dual-boot.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Dualboot consiste en tener dos sistemas operativos en el mismo ordenador y elegir con cuál arrancar durante la fase de boot. Mi objetivo es preparar mi PC para dualboot e instalar Windows 11 Pro. Normalmente se instala primero Windows y Luego Linux, pero en mi caso parto de tener ya Linux (Ubuntu) funcionando perfectamente y ocupando el disco de 4TB por completo.

Voy a "añadir" Windows para poder hacer dualboot. Describo todo el proceso, cómo lo he hecho, cómo he redimensionado el disco duro, añadido windows y personalizado el menú de arranque.

<br clear="left"/>
<style>
table {
    font-size: 0.8em;
}
</style>
<!--more-->

| Este apunte pertenece a una serie:<br><br>• Preparo PC para [Dualboot Linux Windows]({% post_url 2024-08-23-dual-linux-win %}) e instalo Windows 11 Pro.<br>• Configuro [un Windows 11 decente]({% post_url 2024-08-24-win-decente %}), en su esencia, le quito morralla.<br>• Preparo el [Windows para desarrollo]({% post_url 2024-08-25-win-desarrollo %}) de software, CLI, WSL2 y herramientas. |

## Primeros pasos

Los características del mi PC [Slimbook Kymera ATX](https://slimbook.com/kymera-atx)

- Motherboard Gigabyte Z790 UD AX con BIOS F11d y una CPU Intel Core i9-14900K
- Memoria: 96GB (2x48GB) DDR5 6000MT/s / x2 Channel
- Discos: 1 disco 4TB nvme (*principal*) + 2 discos para datos de 2TB SDD
- Sistema con ***UEFI*** y esquema de particionamiento ***GPT***
- Tengo ya Ubuntu 24.04 instalado (Kernel: 6.8.0-41-generic)

Detalles del disco *principal*, de momento solo con linux:

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-01.png"
      caption="Gparted Linux"
      width="500px"
      %}

## Requisitos

Estos son los requisitos que establezco para hacer bien todo el proceso.

- USB para Ubuntu Live (mín. 8GB)
- USB para Windows 11 (mín. 8GB)
- Que el HW cuente con soporte UEFI
- Que la tabla de particiones sea GPT, no MBR
- Conexión a internet para instalar Windows (preferible)
- Backup de Linux (opcional recomendado)

Podría usar una única USB, pero es más cómodo tener dos. Si solo tienes una, primero creas la Live de Ubuntu, arrancas con ella, preparas las particiones, rearrancas con Linux, quemas Windows en tu USB y haces boot con ella para instalarlo.

## Copia de seguridad

Si te equivocas trasteando con las particiones, perderás los datos. Tener una copia de seguridad en un disco externo es casi obligatorio. Que no se diga que no te he avisado.

Usa el sistema que quieras. En mi caso, cuando hago cosas de estas suelo usar [clonezilla](https://clonezilla.org/) y hago una copia completa del disco principal. En este caso es tan grande (4TB) que no tenía otro por ahí de ese tamaño, así que he salvado los archivos principales a un disco externo

## Crear USB con Ubuntu Live

La voy a usar solo para estrechar la partición existente y dejarle sitio a Windows. No lo puedo hacer desde el mismo Linux porque está montada. Descargo la ISO de Ubuntu desde [Download Ubuntu Desktop](https://ubuntu.com/download/desktop) (Desktop 24.04 LTS (6GB)).

Podría haber usado **Startup Disk Creator** (que viene con Ubuntu), pero prefiero quemar la USB con [Balena Etcher](https://etcher.balena.io/#download-etcher) ([guía externa](https://itsfoss.com/install-etcher-linux/)). Me bajo ***Etcher for Linux x64 (64-bit) (zip)***,

```shell
unzip ../Downloads/balenaEtcher-linux-x64-1.19.21.zip
cd balenaEtcher-linux-x64
sudo chown root:root chrome-sandbox
sudo chmod 4755 chrome-sandbox
./balena-etcher.sh
```

***Importante***, saber el nombre del device de tu USB. En mi caso `/dev/sdc`.

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

Importante: asegúrate de elegir el device correcto, el de la USB y no otro.

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

## Crear USB Live con Windows

Primero **descargo Windows 11**, desde el sitio oficial de [descargas](https://www.microsoft.com/software-download/windows11). Sección ISO, opción `Windows 11 (multi-edition ISO for x64 devices)`. Selecciono el Product language y empiezo la descarga (aprox. 6,3GB).

Para pasarla a una USB es sencillo si tienes ya un Windows ([aquí las instrucciones](https://support.microsoft.com/en-us/windows/create-installation-media-for-windows-99a58364-8c02-206f-aa6f-40c3b507420d)). En mi caso lo hago desde mi linux con [Ventoy](https://www.ventoy.net/en/download.html) (una [guía](https://itsfoss.com/use-ventoy/)).

Al instalar Ventoy en la USB, la hace bootable y crea dos particiones, una para él (para que Ventoy haga boot) y otra para copiar el ISO de Windows. Descargo la última versión desde [Ventoy](https://www.ventoy.net/en/download.html).

```shell
cd Downloads
tar xfz ventoy-1.0.99-linux.tar.gz
cd ventoy-1.0.99
sudo ./VentoyWeb.sh
```

Contecto con [http://127.0.0.1:24680](http://127.0.0.1:24680). En `Option` deshabilito *Secure Boot* y selecciono `GPT` como tipo de partición.

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-04.png"
      caption="Quito Secure boot y selecciono GPT"
      width="500px"
      %}

Selecciono la ruta del device donde tengo la USB (en mi caso ahora es `/dev/sdd`) y pulso Install.

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

Hago boot con ***la USB Live de ubuntu***. Le pido a la BIOS hacer boot desde ella. Todos los ordenadores ofrecen mostrar un menú de boot pulsando alguna tecla, del tipo F2/F7/F10/F12/ESC, depende tu BIOS.

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-08.png"
      caption="Selecciono la USB con Ubuntu"
      width="500px"
      %}

Seleccino la USB, pulso Enter. Aparece un menú, selecciono ***Try or Install Ubuntu***, pongo el idioma, accesibilidad, teclado, conexión a internet, me salto actualizar el instalador y selecciono **Try Ubuntu**. Una vez que tengo Ubuntu arrancado, ejecuto la Aplicación Discos (Disks)

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

Rearranco el equipo, quito la USB de Ubuntu y por asegurar, compruebo que puede seguir haciendo boot en la partición redimensionada. Ya estoy listo para instalar Windows

## Instalar Windows

Ahora toca instalar Windows, ten paciencia, tarda bastante, por lo que veo no ha cambiado nada en 25 años. Introduzco la USB con Ventoy + el ISO de Windows 11. Repito el proceso, rearranco el ordenador, pulso mi tecla para que la BIOS muestre las opciones de Boot, selecciono la USB.

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-14.jpg"
      caption="Arranque con Ventoy"
      width="500px"
      %}

Pulso Enter sobre la ISO, selecciono `Boot in normal mode`, veo el logo de Windows. Elijo `idioma y el teclado`, `Instalar ahora`, omito el tema licencia, lo activaré luego. Elijo Windowss 11 Pro, `Install Windows Custom`, me ofrece instalar en la única partición que está vacía `Unalloated Space`. A partir de aquí copia los ficheros y al terminar hace boot, continúa instalando. Nota: en el pasado no siempre hacía esto bien (volvía a hacer boot desde la USB lo cual es incorrecto), tenía que entrar en la BIOS a seleccionando el disco duro.

Como decía, con este ordenador va todo bien, muestra `Getting ready`, reboot, acaba pidiendo país, teclado, updates y otro reboot. Le pongo mote/nombre a mi equipo, reboot, pide cómo lo voy a usar (personal o trabajo). Me gustaría saltarme esta parte pero es imposible (hay un truco pero no lo he seguido). Selecciono "Personal", hago login con mi cuenta de microsoft y continúo configurándolo como equipo nuevo. Creo PIN y le digo que no a localización, buscar dispositivo, diagnósticos, inking, typing, tailored experiences, ads ID, etc. Me salto lo del teléfono, pido que no haga backups, que no importe nada de otro navegador. Hace un útimo update que tarda lo suyo, más reboots, acaba terminando y podemos entrar en Windows.

Aparco el Windows 11 y vuelvo al linux para terminar con el dualboot. Nota: puedes ver en el apunte [Un Windows decente]({% post_url 2024-08-24-win-decente %}) como lo configuro y personalizo.

## Vamos a por el dual boot

Ya tengo Windows. En la BIOS queda como primer Sistema del que hacer boot. Esto no me interesa. Voy a reconfigurar la BIOS para que haga boot con ***Linux*** y configuraré ***grub*** para que sea él el que me muestre un menú de selección (no me gusta el boot manager de Windows).

Reinicio el sistema entro en ***Setup de la BIOS***, cambio la secuencia de arranque, así es como lo tenía, subí Ubuntu hacia arriba para ponerlo el primero.

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-15.jpg"
      caption="Posibilidad de cambiar el orden de Boot en la BIOS"
      width="650px"
      %}

### Añadir Windows a Grub

Una vez en Linux y desde root voy a parametrizar `grub`. Empiezo confirmando que `os-prober` detecta la nueva partición "arrancable" de Windows:

```shell
os-prober

/dev/nvme0n1p1@/EFI/Microsoft/Boot/bootmgfw.efi:Windows Boot Manager:Windows:efi  <-- !! Correcto
````

Edito `/etc/default/grub`, descomento la línea `GRUB_DISABLE_OS_PROBER=false`, de tal manera que `update-grub` use `os-prober` y añada una entrada de menú adicional al fichero `/etc/boot/grub/grub.cfg`

```shell
cat /etc/default/grub | grep PROBER

GRUB_DISABLE_OS_PROBER=false
```

Ejecuto `update-grub` para que me añada la partición Windows al fichero de configuración (`/boot/grub/grub.cfg`) como un elmento del menú de arranque.

```shell
update-grub

:
Sourcing file `/etc/default/grub'
Warning: os-prober will be executed to detect other bootable partitions.
:
Found Windows Boot Manager on /dev/nvme0n1p1@/EFI/Microsoft/Boot/bootmgfw.efi
:
```

Nota: Yo volví a dejar esta línea comentada `#GRUB_DISABLE_OS_PROBER=false` en el `/etc/default/grub` y volver a ejecutar `update-grub`, ya no me hace falta que detecte nada.

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

Dejo aquí algunos cambios que hice al final sobre el fichero `/etc/default/grub` a modo de referencia.

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

Ejecuto el update y hago un reboot

```shell
update-grub
reboot -f
```

{% include showImagen.html
      src="/assets/img/posts/2024-08-23-dual-linux-win-19.png"
      caption="Nuevo look & feel de mi menú de arranque"
      width="650px"
      %}

Listo, ya tengo dualboot. Continúo con mi siguiente apunte, sobre cómo configurar y dejar mi Windows 11 [lo más decente]({% post_url 2024-08-24-win-decente %}) posible.

## Sobre dualboot y la hora

Antes de terminar, te dejo aquí algo que puede que necesites. Cuando se hace **Dual Boot entre Windows y Linux te puedes encontrar un problema antiguo y conocido, que uno de los dos muestre mal la hora**.

El motivo es que, por defecto, Windows tiende a interpretar que el reloj Hardware del PC (el RTC) tiene puesta tu hora LOCAL, mientras que Linux tiende a interpretar que el reloj Hardware del PC tiene puesta la hora UTC (que es como debería ser).

- Si la BIOS tiene LOCAL - Windows feliz, pero Linux se confunde, muestra mal la hora, a no ser que tenga bien configurado NTP (coger la hora de internet).
- Si la BIOS tiene UTC - Linux feliz, pero Windows se confunde, muestra mal la hora, a no ser que NTP esté bien (ojo! no siempre ocurre)

Si no haces nada y te fías de NTP y te funciona, aparentemente todo estará bien, pero la realidad es que está mal, no hay coherencia. De hecho esto te puede despistar en el futuro.

¿Qué debería hacer?, hay varias opciones y varios artículos por ahí (ejemplo [aquí](https://itsfoss.com/wrong-time-dual-boot/) y [aquí](https://www.howtogeek.com/323390/how-to-fix-windows-and-linux-showing-different-times-when-dual-booting/))

Lo que hago en mi caso es ser coherente: Pongo UTC en la BIOS y hago un cambio en Windows.

1. **Pongo la hora UTC en el Hardware del PC en la BIOS**. Es lo recomendado, todos los Sistemas Operativos usan internamente UTC **siempre**, las fechas de los archivos en el File System siempre son UTC. Otra cosa es lo que te enseña, que depende del Timezone configurado.
   Por lo tanto, en mi PC, entro en la BIOS, y como estoy en Madrid en verano, pues pongo 2 horas menos. Puedes ver cual es la hora UTC [aquí](https://www.timeanddate.com/worldclock/timezone/utc)
2. **Linux**: **No hago nada**, es lo que espera y se adapta correctamente, tanto si tiene NTP bien como mal configurado.
3. **Windows**: **Le digo que el Hardware del PC tiene la hora universal (UTC)**, no LOCAl.
   - `regedit`
   - `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation`
   - Añado una cadena/string `RealTimeIsUniversal` con valor `1`
   - Rearranco el equipo
4. En ambos, configuro NTP Client, que sincronice sus relojes con servidores NTP de internet
5. En ambos configuro mi Zona Horaria (timezone), en mi caso a `Europe/Madrid` con soporte de horario de verano.
