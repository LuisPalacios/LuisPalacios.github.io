---
title: "Rsync en MacOS"
date: "2006-11-13"
categories: herramientas
tags: cliente servidor mac linux
excerpt_separator: <!--more-->
---


![logo rsync](/assets/img/posts/rsync.svg){: width="150px" height="114px" style="float:left; padding-right:25px" } 

El programa rsync viene incluido con Mac OSX pero si necesitas una versión más moderna y que soporte más funcionalidades, como por ejemplo preservar metadatos, soporte de caracteres extendidos o caracteres multiplataforma entonces vas a tener que instalarte una de las últimas versiones.

<br clear="left"/>
<!--more-->

Para poder compilar la última versión necesitarás:

- Saber utilizar Terminal.app
- Tener instaladas las Apple Developer Tools

Los pasos para realizar la instalación son los siguientes. Cuando lo hice se trataba de la versión 3.1.0 que compilé en MacOSX 10.8.5 en modo 64 bits. Como root:

```zsh
 cd /tmp
 curl -O http://rsync.samba.org/ftp/rsync/rsync-3.1.0.tar.gz
 tar -xzvf rsync-3.1.0.tar.gz
 rm rsync-3.1.0.tar.gz
 curl -O http://rsync.samba.org/ftp/rsync/rsync-patches-3.1.0.tar.gz
 tar -xzvf rsync-patches-3.1.0.tar.gz
 rm rsync-patches-3.1.0.tar.gz
 cd rsync-3.1.0
 patch -p1 < patches/fileflags.diff
 patch -p1 < patches/crtimes.diff
 ./prepare-source
 ./configure
 make
 make install
 mv /usr/local/bin/rsync /usr/bin
````

<br/>

## Instalación daemon rsyncd en MacOSX

Si lo consideras necesario puedes actualizar a la última versión de rsync tal como describo más arriba. En cualquier caso lo que describo a continuación vale tanto para la última versión como para versiones anteriores.

En esta sección vamos a ver cómo configurar el MacOSX para que arranque "rsync" en modo daemon, o lo que es lo mismo, se ejecute el comando `rsync --daemon` en el background.

Para poder ejecutar un "daemon" en el Mac y que arranque en cada boot hay que usar "launchd" y "launchdctl" para cargar un fichero XML que describa qué proceso quieres ejecutar en modo daemon. El fichero XML es un fichero "PLIST o property list" que se instala como root en /Library/LaunchDaemon.

Así que allá vamos. Crear el fichero `org.samba.rsync.plist`

```xml
{% raw %}
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>Disabled</key>
        <false/>
        <key>Label</key>
        <string>org.samba.rsync</string>
        <key>Program</key>
        <string>/usr/bin/rsync</string>
        <key>ProgramArguments</key>
        <array>
                <string>/usr/bin/rsync</string>
                <string>--daemon</string>
		<string>--config=/etc/rsyncd.conf</string>      
        </array>
        <key>inetdCompatibility</key>
        <dict>
                <key>Wait</key>
                <false/>
        </dict>
		<key>Sockets</key>
		<dict>
			<key>Listeners</key>
			<dict>
				<key>SockServiceName</key>
				<string>rsync</string>
				<key>SockType</key>
				<string>stream</string>
			</dict>
		</dict>
</dict>
</plist>
{% endraw %}
```          
         
Desde Terminal.app y como root copio el fichero a /Library/LaunchDaemons

```zsh
cp org.samba.rsync.plist /Library/LaunchDaemons/
```

Creo el fichero /etc/rsyncd.conf

```
pid file = /var/run/rsyncd.pid
use chroot = yes
read only = yes
charset = utf-8
 
\[Datos\]
 path=/Volumes/Datos
 comment = Repositorio de Luis
 uid = luis
 gid = luis
 list = yes
 read only = false
 auth users = luis
 secrets file = /etc/rsync/rsyncd.secrets
```

Fichero de secretos /etc/rsync/rsyncd.secrets. Usar la misma contraseña (Clean) que usará el cliente.

```
luis:CONTRASEÑA
```

```
chmod 400 rsyncd.secrets 
```

Cargo el plist en el registro de launchd. El proceso "rsync --daemon" no arranca, lo que estamos haciendo es que se registre el servicio y cuando llegue una petición al puerto 783 el proceso launchd se encargará de arrancar "rsync --daemon".

```
netstat -na|grep 873
```

```
:
# launchctl load -w /Library/LaunchDaemons/org.samba.rsync.plist 
# netstat -na|grep 873
tcp6 0 0 \*.873 \*.\* LISTEN 
tcp4 0 0 \*.873 \*.\* LISTEN
```

Desde un cliente podemos comprobar que está funcionando

```
$ rsync --stats luis@miservidor.midominio.com::Datos
Password: 
:
sent 58 bytes received 618 bytes 193.14 bytes/sec
total size is 24580 speedup is 36.36
```
