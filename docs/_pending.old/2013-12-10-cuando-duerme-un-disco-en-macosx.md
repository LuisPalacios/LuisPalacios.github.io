---
title: "Cuándo duerme un disco en MacOSX"
date: "2013-12-10"
categories: macos
tags: disco macosx
excerpt_separator: <!--more-->
---

![duermetedisco](/assets/img/original/duermetedisco.png){: width="730px" padding:10px }

Necesito subir el tiempo que esperará el MacOSX antes de poner a dormir un disco duro externo Thunderbolt.

Por defecto son diez minutos. El comando para ver la configuración actual es:

 
obelix:~ luis$ sudo pmset -g
Active Profiles:
AC Power 2*
Currently in use:
 standby 1
 Sleep On Power Button 1
 womp 1
 halfdim 1
 hibernatefile /var/vm/sleepimage
 darkwakes 1
 autorestart 0
 networkoversleep 0
 disksleep 10   <=========== !!!!!!
 sleep 1
 autopoweroffdelay 14400
 hibernatemode 0
 autopoweroff 1
 ttyskeepawake 1
 displaysleep 10
 standbydelay 10800
 

Para subirlo a 20 minutos simplemente ejecutar lo siguiente:

 
obelix:~ luis$ sudo pmset -a disksleep 20
Warning: Idle sleep timings for "AC Power" may not behave as expected.
- Display sleep should have a lower timeout than system sleep.
