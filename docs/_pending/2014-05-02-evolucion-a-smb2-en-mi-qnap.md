---
title: "Evolución a SMB2 en mi QNAP"
date: "2014-05-02"
categories: apuntes
tags: afp qnap samba smb2
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/sambaqnap.jpg"
    caption="samba+qnap"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/?p=684"
    caption="backups desatendidos con GoodSync"
    width="600px"
    %}

**Qué es "SMB", "CIFS", "Samba" y los líos de las versiones :-)** SMB (Server Message Block) es un "Protocolo" de red que entre otras cosas hace posible la compartición de archivos e impresoras entre nodos de una red. Lo inventó IBM, pero el que lo modificó, lo llevó a la fama y hoy en día mantiene y sigue ampliando es Microsoft.

CIFS (Common Internet File System) es un "Dialecto" de SMB. Un dialecto es un conjunto de "mensajes" que definen una versión particular del protocolo SMB. Microsoft implementa SMB en sus equipo y añadió múltiples mejoras en su dialecto CIFS.

Samba es una implementación libre del protocolo SMB (o llámalo CIFS si quieres) que está disponible en plataformas GNU/Linux (por ejemplo el QNAP), Mac OS X o Unix.

- SAMBA 3.5.2 usa SMB1 (estable y muy implementado)
- SAMBA >= 3.6.0 usa SMB2 (en 2014 entra en pista en QNAP, MacOSX, …)
- SAMBA >= 4.0.0 usa SMB3 (en 2014 un año en “desarrollo", estable, poco implementado)

He instalado la versión 4.1 del software de QNAP y como se puede ver ya incorpora el soporte de Samba 3.6.x, seleccionando la opción SMB 2.1 en las opciones avanzadas.

{% include showImagen.html
    src="/assets/img/original/SMBavanzado.png"
    caption="SMBavanzado"
    width="600px"
    %}

obelix:~ luis$ ssh -l admin panoramix.parchis.org
[~] # 
[~] # /mnt/ext/opt/samba/sbin/smbd -V 
Version 3.6.23
 

 

## SMB2 versus AFP

{% include showImagen.html
    src="/assets/img/original/OSX_Mavericks_Core_Technology_Overview.pdf"
    caption="OSX Mavericks Core Technology Overview, pagina 21"
    width="600px"
    %}

  ___SMB2___ SMB2 is the new default protocol for sharing files in OS X Mavericks. SMB2 is superfast, increases security, and improves Windows compatibility. • Efficient. SMB2 features Resource Compounding, allowing multiple requests to be sent in a single request. In addition, SMB2 can use large reads and writes to make better use of faster networks as well as large MTU support for blazing speeds on 10 Gigabit Ethernet. It aggressively caches file and folder properties and uses oppor- tunistic locking to enable better caching of data. It’s even more reliable, thanks to the ability to transparently reconnect to servers in the event of a temporary disconnect. • Secure. SMB2 supports Extended Authentication Security using Kerberos and NTLMv2. • Compatible. SMB2 is automatically used to share files between two Mac computers running OS X Mavericks, or when a Windows client running Vista, Windows 7, or Windows 8 connects to your Mac. OS X Mavericks maintains support for AFP and SMB network file-sharing protocols, automatically selecting the appropriate protocol as needed.   ___AFP___ The Apple Filing Protocol (AFP) is the traditional network file service used on the Mac. Built-in AFP support provides connectivity with older Mac computers and Time Machine–based backup systems.     ___NFS___ NFS v3 and v4 support in OS X allows for accessing UNIX and Linux desktop and server systems. With AutoFS, you can now specify automount paths for your entire organiza- tion using the same standard automounter maps supported by Linux and Solaris. For enhanced security, NFS can use Kerberos authentication as an alternative to UNIX UID-based authentication.  

 

Esta es la razón principal por la que he decidido dejar de usar AFP y pasar a SMB(2) en la conexión de mis MacOSX al servicio de ficheros de QNAP. Paso a usar smb:// en vez de afp:// cuando conecto con los volúmenes compartidos, de hecho he desactivado AFP en el QNAP.

 

## Curiosidades de SMB2 en QNAP

Hay un par de cosas que he detectado como "curiosas". La primera es que hay que tener cuidado con no usar ciertos caracteres en los nombres de los ficheros y la segunda es que QNAP no soporta ciertas extensiones en atributos de ficheros (lo detecté al ver que GoodSync se queja al copiar algunos ficheros).

{% include showImagen.html
    src="/assets/img/original/Filename#Comparison_of_filename_limitations"
    caption="artículo interesante sobre las limitaciones dependiendo del sistema operativo"
    width="600px"
    %}

2) Sobre los atributos extendidos que algunos de mis ficheros en mi Mac tienen y que GoodSync intenta poner al escribirlos en al red... pues he visto que en algunos casos "NO" puede y simplemente no puede poner dichos atributos extendidos a la copia de la red. No es grave, porque el fichero sí se copia perfecto y funciona, pero "algún" atributo no está viajando a mi file system en la red. Es algo que tengo que investigar más en detalle.

## Caracteres no recomendados

He desarrollado una pequeña herramienta que te va a permitir detectar si el nombre de alguno de tus ficheros y/o directorios contiene caracteres "peculiares". ¿Para qué sirve? pues para estar avisado, dado que si intentas copiar dichos archivos (con ciertos caracteres raros) a tu NAS, puede que a ésta no le guste demasiado. Ah!, también sirve para "cambiar" los caracteres por otros sustitutivos (aunque ojo con esa opción que es muy intrusiva...)

El programa se ejecuta desde la línea de comandos (Terminal.app o iTerm) y puedes hacerlo en modo "informativo" o en modo "intrusivo = cambia los caracteres peculiares por otros más sanos". Además soporta dos conjuntos de caracteres que divido entre caracteres por los que voy a AVISARTE (WARNING SET) o caracteres que deberías CAMBIAR (MUST-SWAP). Los caracteres que van en cada conjunto son:

- WARNING SET |?*<":>/
- MUST-SWAP :?

{% include showImagen.html
    src="/assets/img/original/sanato) (del latín: curación"
    caption=""sanato""
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/Captura-de-pantalla-2014-12-23-a-las-17.35.03.png"
    caption="Captura de pantalla 2014-12-23 a las 17.35.03"
    width="600px"
    %}

Ten cuidado porque hay aplicaciones o documentos que dentro de su bundle pueden tener este tipo de caracteres, ya que son perfectamente válidos. Te recomiendo usarlo solo para tus propios ficheros, fotos, videos, documentos que vas a guardar en tu servidor de ficheros QNAP. Recuerda que el programa tiene opción de sanear esos dos ":?" caracteres, por lo tanto **sí que renombra** el fichero o directorio (cambia esos dos caracteres por un guión '-'), así que úsala con cuidado.
