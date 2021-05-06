---
title: "X11 forwarding vía ssh después de hacer \"su\""
date: "2017-02-11"
categories: apuntes
tags: afp linux
excerpt_separator: <!--more-->
---

Me han preguntado últimamente cómo hacer que esto funcione así que mejor es explicarlo en un apunte y así me vale a mi porque siempre tengo que buscar cual era el comando o la mejor solución. Explico el problema, presento la solución técnica y luego un truco buenísimo que es el que uso yo (ver _Solución permanente_ al final).

### El problema

Partimos de un servidor linux llamado `marte` con el servicio `sshd` y `X11 Forwarding` activo. Cuando conecto con un usuario normal (p.e.: `luis`) y ejecuto un programa X11 (p.e.: `xclock`), pues todo va bien. Ahora, en cuanto ejecuto "`su -`" o "`sudo su -`" para convertirme en root e intento `xclock` de nuevo ya no va.

ˋˋˋ ssh -a -Y -l luis marte.parchis.org luis@marte.parchis.org's password: luis@marte:~$ luis@marte:~$ xclock <=== FUNCIONA ^C luis@marte:~$ su - <=== O bien "sudo su -" root@marte:~# xclock <=== FALLA Error: Can't open display: localhost:10.0 ˋˋˋ

ssh -a -Y -l luis marte.parchis.org
luis@marte.parchis.org's password:
luis@marte:~$
luis@marte:~$ xclock <=== FUNCIONA
^C
luis@marte:~$ su - <=== O bien "sudo su -"
root@marte:~# xclock <=== FALLA
Error: Can't open display: localhost:10.0

### La solución (parcial)

La autenticación X se basa en **cookies,** básicamente un chorro de datos que solo el servidor y tu usuario conocen. En el ejemplo anterior cuando `luis` conecta vía `ssh` con el servidor `marte` todo funciona, la primera vez se crea dicha cookie y se archiva en el directorio `HOME` del usuario `luis` (`~/.Xauthority`).  Para que también nos funcione al convertirnos en `root` tenemos que pasarle dicha cookie.

Lo primero es averiguar la cookie de `luis` para el valor de la variable `DISPLAY` actual:

ssh -a -Y -l luis marte.parchis.org
luis@marte.parchis.org's password:
luis@marte:~$ xauth list $DISPLAY
marte/unix:10 MIT-MAGIC-COOKIE-1 d0e149825311234567855be818cb1ebf

Después entramos en "`su -`" o "`sudo su -`" y ya como root añadimos la cookie. La primera vez se quejará de que el fichero `.Xauthority` no existe, simplemente ignóralo porque lo va a crear.

luis@marte:~$ s
root@marte:~# xauth add marte/unix:10 MIT-MAGIC-COOKIE-1 d0e149825311234567855be818cb1ebf
xauth: file /root/.Xauthority does not exist
root@marte:~# ls -al .Xauthority
-rw------- 1 root root 51 feb 11 12:32 .Xauthority
root@marte:~# xclock    <== FUNCIONA !!!!!!
^C

{% include showImagen.html
    src="/assets/img/original/x11fwdsu.png"
    caption=""
    width="600px"
    %}

Hasta aquí todo bien pero no es permanente, por ejemplo al re-arrancar el servidor, el sshd, etc... se regenerarán los cookies y tendríamos a volver a empezar.

### Solución permanente

Ahora que hemos entendido cómo funciona te presento la mejor solución,

/root/.profile
export XAUTHORITY=/home/luis/.Xauthority

Consiste en usar la variable de entorno `XAUTHORITY` apuntando al fichero `.Xauthority` del usuario (en mi ejemplo `luis`), la pones en el `.profile` de root y ya está. **No necesitas** ejecutar el comando `xauth` y **no necesitas** el fichero `/root/.Xauthority`.
