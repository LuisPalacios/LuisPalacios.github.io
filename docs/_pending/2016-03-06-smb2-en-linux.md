---
title: "SMB2 en Linux"
date: "2016-03-06"
categories: apuntes gentoo
tags: cifs samba smb smb2
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/samba.jpg"
    caption="samba"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/?p=665"
    caption="apunte sobre SMB y QNAP"
    width="600px"
    %}

**SMB (Server Message Block)** es un "Protocolo" de red que entre otras cosas hace posible la compartición de archivos e impresoras entre nodos de una red. Lo inventó IBM, pero el que lo modificó, lo llevó a la fama y hoy en día mantiene y sigue ampliando es Microsoft. **CIFS (Common Internet File System)** es un "Dialecto" de SMB. Un dialecto es un conjunto de "mensajes" que definen una versión particular del protocolo SMB. Microsoft implementa SMB en sus equipos y añadió múltiples mejoras en su dialecto CIFS. **Samba** es una implementación libre del protocolo SMB (o llámalo CIFS si quieres) que está disponible en plataformas GNU/Linux (por ejemplo el QNAP), Mac OS X o Unix.

- SAMBA 3.5.2 usa SMB1 (estable y muy implementado)
- SAMBA >= 3.6.0 usa SMB2 (entró en pista en 2014 en QNAP, MacOSX, …)
- SAMBA >= 4.0.0 usa SMB3 (ya por el 2014 estaba en “desarrollo", estable y poco implementado)

{% include showImagen.html
    src="/assets/img/original/OSX_Mavericks_Core_Technology_Overview.pdf"
    caption="OSX Mavericks Core Technology Overview, pagina 21"
    width="600px"
    %}

 

## Instalación del Servidor

Se trata de un Linux con Gentoo e instalo Samba (versión 3.6.x // SMB2)

# emerge -v samba
[ebuild  N     ] net-fs/samba-3.6.25::gentoo  USE="acl aio client cups fam ldap netapi pam readline server smbclient winbind -addns -ads -avahi -caps -cluster -debug -dmapi -doc -examples -ldb -quota (-selinux) -smbsharemodes -swat -syslog" ABI_X86="(64) -32 (-x32)" 33.323 KiB
:

 

### Configuración

Preparo el fichero `smb.conf`. En este ejemplo voy a compartir un único directorio llamado `/cloud`

 # cd /etc/samba/
 # confcat smb.conf
[global]
   workgroup = WORKGROUP
   server string = Cloud Server
   security = user
   hosts allow = 192.168.1. 127.
   log file = /var/log/samba/log.%m
   max log size = 50
   passdb backend = tdbsam
   local master = no
   domain master = auto
   preferred master = no
   dns proxy = no
   max protocol = SMB2_10
   display charset = UTF8
   max xmit = 65535
   socket options = TCP_NODELAY IPTOS_LOWDELAY SO_SNDBUF=65535 SO_RCVBUF=65535 SO_KEEPALIVE
   read raw = yes
   write raw = yes
   max connections = 65535
   max open files = 65535
[Cloud]
comment = Disco Cloud
path = /cloud
browsable = yes
oplocks = yes
ftp write only = no
recycle bin = no
recycle bin administrators only = no
public = yes
invalid users = "nobody"
read list =
write list = "luis"
valid users = "root","luis"
inherit permissions = yes
smb encrypt = disabled
mangled names = yes

&mbsp;

### Configuración

Arranco el servicio y lo configuro para que arranque de forma automática en el próximo boot

# systemctl start smbd
# systemctl enable smbd

 

### tdbsam

El backend para guardar el nombre/contraseña de los usuarios de Samba puede ser: `smbpasswd`, `tdbsam` o `ldapsam`. Para entornos simples (caseros) el recomendado es `tdbsam`, formato “TDB” (trivial database). Las dos líneas relacionadas en la sección `[global]`de la configuración son:

   security = user
   passdb backend = tdbsam

El siguiente paso es crear las cuentas en Samba, en este ejemplo creo solo una:

# pdbedit -a luis
Unix username:        luis
NT username:
Account Flags:        [U          ]
User SID:             S-1-5-21-1234567-123456789-1234567890-1011
Primary Group SID:    S-1-5-21-1234567-123456789-1234567890-523
Full Name:
Home Directory:       \\server\luis
HomeDir Drive:
Logon Script:
Profile Path:         \\server\luis\profile
Domain:               SERVER
Account desc:
Workstations:
Munged dial:
Logon time:           0
Logoff time:          mié, 06 feb 2036 16:06:39 CET
Kickoff time:         mié, 06 feb 2036 16:06:39 CET
Password last set:    dom, 06 mar 2015 10:47:22 CET
Password can change:  dom, 06 mar 2015 10:47:22 CET
Password must change: never
Last bad password   : 0
Bad password count  : 0
Logon hours         : FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

Por si acaso lo necesitas, echa un ojo al comando \`pbedit\`, puedes borrar cuentas con \`pdbedit -x usuario\` o ver el detalle de una cuenta creada con \`pdbedit -Lv usuario\`.

## Cliente OSX

Desde el Finder conecto con el servicio. Es tan sencillo como pulsar CMD+K en el Finder y escribir la notación apropiada

{% include showImagen.html
    src="/assets/img/original/SMB2-1.png"
    caption="SMB2-1"
    width="600px"
    %}

Nos pedirá la contraseña del usuario, que puedo guardar en el Llavero para que la próxima vez ya no la solicite

{% include showImagen.html
    src="/assets/img/original/SMB2-2.png"
    caption="SMB2-2"
    width="600px"
    %}
