---
title: "Gentoo en NUC: Configuración mínima"
date: "2014-10-29"
categories: apuntes
tags: macosx peakhour snmp
excerpt_separator: <!--more-->
---

Este apunte se centra en la configuración mínima que suelo hacer tras terminar la instalación del equipo y preparar las particiones del disco. Te recomiendo que eches un ojo a la ![instalación de Gentoo GNU/Linux en un Intel® NUC D54250WYK](/assets/img/original/?p=7){: width="730px" padding:10px }, si no lo has hecho ya.

![minimo](/assets/img/original/minimo.png){: width="730px" padding:10px }

Lo primero es lo primero, dejo aquí un ![enlace a los ficheros](/assets/img/original/?p=785){: width="730px" padding:10px } que utilizo en mi instalación, después lo que tengo que hacer son algunos ajustes mínimos para dejar preparada la instalación:

Leer las news

 
 
(chroot) livecd usr # eselect news list
(chroot) livecd usr # eselect news read ’n’
 

Zona horaria

 
 
(chroot) livecd usr # cd /
(chroot) livecd / # echo "Europe/Madrid" > /etc/timezone
(chroot) livecd / # emerge --config sys-libs/timezone-data
Configuring pkg...
* Updating /etc/localtime with /usr/share/zoneinfo/Europe/Madrid
 

Portage, elegir el Perfil adecuado

 
 
(chroot) livecd portage # eselect profile list
Available profile symlink targets:
[1] default/linux/amd64/13.0
:
(chroot) livecd portage # eselect profile set 1
 

Nota: He decidido no utilizar systemd debido a la inestabilidad de su interoperabilidad y cohesión en su desarrollo, quizá más adelante si se calman los ánimos en la comunidad. Opto por seguir con sysvinit, openrc y baselayout2

Sincronizar portage

 
 
(chroot) livecd usr # emerge —sync
 

Preparar la compilación

Antes de poder compilar nada hay que preparar al menos cuatro ficheros de Portage, así que revisa ![los Ficheros de Configuración](/assets/img/original/?p=785){: width="730px" padding:10px }

Bloqueo de "systemd" y “udev”

Lo comenté antes, "NO" voy a usar systemd ni udev, sino la versión (fork) de Gentoo "eudev", así que es muy importante que "bloqueemos" ambos para que no nos den el rollo. Se hace en uno de los ficheros de Portage.

sys-apps/systemd
sys-fs/udev

![Stage3](/assets/img/original/udev, así que al bloquearlos vamos a tener que ejecutar un update (emerge -DuvN system world). De momento solo aviso, pero es importante y veremos cómo lo ejecuto justo antes de hacer el primer boot (desde SSD){: width="730px" padding:10px }

Instalo eix y genlop

 
 
# emerge -v eix genlop
# eix-update
 

Configuro el locale

en_US ISO-8859-1
en_US.UTF-8 UTF-8
es_ES ISO-8859-1
es_ES@euro ISO-8859-15
es_ES.UTF-8 UTF-8
en_US.UTF-8@euro UTF-8
es_ES.UTF-8@euro UTF-8

 
 
(chroot) livecd / # locale-gen
* Generating 7 locales (this might take a while) with 1 jobs
* (1/7) Generating en_US.ISO-8859-1 ... [ ok ]
* (2/7) Generating en_US.UTF-8 ... [ ok ]
* (3/7) Generating es_ES.ISO-8859-1 ... [ ok ]
* (4/7) Generating es_ES.ISO-8859-15@euro ... [ ok ]
* (5/7) Generating es_ES.UTF-8 ... [ ok ]
* (6/7) Generating en_US.UTF-8.UTF-8@euro ... [ ok ]
* (7/7) Generating es_ES.UTF-8.UTF-8@euro ... [ ok ]
* Generation complete
 
(chroot) livecd / # eselect locale list
:
[10] es_ES.utf8
 
(chroot) livecd / # eselect locale set 10
Setting LANG to es_ES.utf8 ...
Run ". /etc/profile" to update the variable in your shell.
 

LC_ALL="es_ES.UTF-8"
LC_COLLATE="es_ES.UTF-8"
LC_CTYPE="es_ES.UTF-8"
LC_MESSAGES="es_ES.UTF-8"
LC_MONETARY="es_ES.UTF-8"
LC_NUMERIC="es_ES.UTF-8"
LC_PAPER="es_ES.UTF-8"
LANG="es_ES.UTF-8"

Importante recargar el entorno de la shell antes de continuar

 
 
(chroot) livecd / # env-update && source /etc/profile
>>> Regenerating /etc/ld.so.cache...
livecd / # export PS1="(chroot) $PS1"
(chroot) livecd / #
 

Volver al paso anterior: [Descargar Stage 3, Portage y entrar en el nuevo entorno (chroot)](https://www.luispa.com/?p=800) o ir al siguiente: ![Instalación del kernel](/assets/img/original/?p=831){: width="730px" padding:10px }
