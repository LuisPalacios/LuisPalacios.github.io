---
title: "Raspberry Pi OS"
date: "2023-03-02"
categories: linux
tags: raspberry pi 64bits
excerpt_separator: <!--more-->
---


![logo linux router](/assets/img/posts/logo-raspberry.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Este apunte describo el proceso de instalación de una **Raspberry Pi 4 Model B Rev 1.5** con el sistema operativo basado en Debian **Raspberry Pi OS (64bits)**. Va a ser un mini servidor para distintas pruebas y tareas.

<br clear="left"/>
<!--more-->

### Tarjeta SD

Lo primero es lo primero, preparar una tarjeta Micro SD con el sistema operativo, he elegido Raspbian OS Lite 64bits. No necesito la parte gráfica, voy a utilizarlo como un servidor corriendo diferentes servcios. Podemos usar cualquier método para clonar la imagen en una tarjeta SD, en mi caso he usado programa **Raspberry Pi imager**.


{% include showImagen.html
    src="/assets/img/posts/2023-03-02-raspberry-pi-os-01.png"
    caption="Preparo la tarjeta SD con Raspberry Pi imager"
    width="500px"
    %}
{% include showImagen.html
    src="/assets/img/posts/2023-03-02-raspberry-pi-os-02.png"
    caption="Selecciono Raspberry Pi OS (64bits)"
    width="500px"
    %}
{% include showImagen.html
    src="/assets/img/posts/2023-03-02-raspberry-pi-os-03.png"
    caption="Selecciono el dispositivo donde grabar la imagen"
    width="500px"
    %}

Cuando termina retiro la tarjeta y la introduzco en la Pi. Conecto la Pi a un monitor, teclado y conecto con **cable ethernet al switch**, para iniciar la primera fase de la instalación, donde es importante tener acceso a Internet. La Pi recibirá una dirección IP vía DHCP inicialmente.

<br/>

### Primera fase de la instalación.

Un rato después de arrancar la Pi empezaremos a ver una serie de menús donde hacemos la configuración básica. A continuación describo lo que configuré en mi caso:

- Layout del Teclado: `Other -> Spanish`, `Spanish`
- New Username: `luis`
  
Hago login con el usuario y contraseña que acabo de configurar y lo primero que voy a hacer es activar `sshd` para poder conectar con la Pi a través de la red local y continuar desde ahí.

```console
raspberrypi Login: luis
Password: <la del paso anterior>

luis@raspberrypi:~ $ sudo raspi-config
```

Selecciono **Interface options -> SSH -> Ok**, arrancará el servicio SSHD. Me salgo de `raspi-config` y averiguo qué dirección IP ha recibido de la red.

```console
$ sudo ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.82  netmask 255.255.255.0  broadcast 192.168.1.255
             ============
:
```

Me conecto desde mi puesto de trabajo

```console
$ ssh pi@192.168.1.82
:
Last login: Tue Feb 21 04:29:57 2023
-bash: warning: setlocale: LC_ALL: cannot change locale (es_ES.UTF-8)

Wi-Fi is currently blocked by rfkill.
Use raspi-config to set the country before use.

pi@raspberrypi:~ $
```

Vuelvo a entrar en `raspi-config` para terminar de configurar múltiples aspectos importantes: 

* `System Options > hostname > "idefix"`
* `Localisation Options > Locale >`
  * `[ ] en_GB.UTF-8 UTF-8`
  * `[*] es_ES.UTF-8 UTF-8`
  * `Default Locale: es_ES.UTF-8 UTF-8`
* `Localisation Options > Timezone > Europa, Madrid`
* `Localisation Options > WLAN Country > ES`
* `Advance Options > Network intLocalisation Options > WLAN Country > ES`
* `Finish y Reboot`

Por último hacemos una actualización del sistema operativo !

```console
# apt update && apt upgrade -y && apt full-upgrade -y
```

<br/>

### YA ESTÁ !!!

Tengo una Raspberry Pi perfectamente operativa, actualizada a la última versión de Raspberry OS de 64 bits y con el último Kernel 6.1 que es lo que estaba disponible en la fecha de esta publicación. 

<br/>

### Personalización

Esta parte del proceso es opcional, a mi me gusta tener algunos ficheros y scripts de apoyo en todos los sistemas linux con los que trabajo y algunas modificaciones al sistema. Los dejo aquí como referencia. 

<br />

#### Elimino IPv6, WLAN, BT

De nuevo opcional, solo si lo necesitas, así es como se elimina IPv6, la tarjeta Wifi de la Pi y el Bluetooth. En mi caso cuando hago laboratorios de IPv4 y no lo necesito prefiero desactivarlo todo.

* Fichero `/boot/cmdline.txt`, añado al final de la línea `ipv6.disable=1`

```console
console=serial0,115200 console=tty1 root=PARTUUID=2c310193-02 rootfstype=ext4 fsck.repair=yes rootwait ipv6.disable=1
```

* Fichero `/boot/config.txt`, añado al final del fichero dos líneas adicionales:

```console
:
dtoverlay=disable-wifi
dtoverlay=disable-bt
```

* Recuerda que para que estos cambios sean efectivos tienes que hacer un `reboot` de la Pi.


<br />

#### Ficheros y scripts

Si los quieres instalar bájate los gists y dales permiso de ejecución. Para instalarlos, a continuación un ejemplo: haz clic en el enlace (p.ej. el de `/usr/bin/e`), selecciánalo todo y copia con Ctrl-C. Depués usa `cat` y cambia los permisos: 

```console
luis@idefix:~ $ sudo su -
root@dubai:~# cat > /usr/bin/e
Ctrl-V             <=== Pego el contenido del gist

Intro              <=== Crear nueva línea vacía al final, antes de pulsar Ctrl-D
Ctrl-D             <=== Salgo
root@dubai:~# chmod 755 /usr/bin/e
```

- Script [/usr/bin/e](https://gist.githubusercontent.com/LuisPalacios/14b0198abc35c26ab081df531a856971/raw/8b6e278b4e89f105b2d573ebc79c67e915e6ab47/e)
- Fichero [/etc/nanorc](https://gist.githubusercontent.com/LuisPalacios/4e07adf45ec1ba074939317b59d616a4/raw/b50efd22130a0129e408bca10fc7b8dbab7e03ff/nanorc) personalizado para el editor nano
- Creo el directorio de backup para nano tanto para `root` como para mi usuario.
  - `luis@idefix:~ $ sudo mkdir /root/.nano`
  - `luis@idefix:~ $ mkdir ~/.nano`
- Script [/usr/bin/confcat](https://gist.githubusercontent.com/LuisPalacios/d646638f7571d6e74c20502b3033cf07/raw/f0f015d9b1d806919ec0295a22f3710b4f3096e0/confcat) que muestra archivos quitando las líneas de comentarios
- Script [/usr/bin/s](https://gist.githubusercontent.com/LuisPalacios/8e334583ad28e681326c65b665457eaa/raw/201a2ace950dcbb14b341b31ae70c9fffde29540/s) para cambiar a root mucho más rápido
- Recuerda cambiar los permisos
  - `luis@idefix:~ $ sudo chmod 755 /usr/bin/e /usr/bin/confcat /usr/bin/s`

El fichero `/etc/sudoers.d/010_pi-nopasswd` ya viene preparado para que al usuario `luis` no le pida contraseña de root y pueda ejecutar `sudo` directamente. 

A partir de ahora al ejecutar el comando `e fichero` se arrancará el editor `nano`. El editor funcionará con el esquema de teclado descrito en `/etc/nanorc`. Al ejecutar `s` me convertiré en `root` y por último el comando `confcat` muestra el contenido de archivos de texto ignorando las líneas de comentarios.

