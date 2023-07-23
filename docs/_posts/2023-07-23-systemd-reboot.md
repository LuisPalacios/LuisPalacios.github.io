---
title: "Reboot diario con Systemd"
date: "2023-07-23"
categories: infraestructura
tags: linux reboot systemd diario programado rearranque
excerpt_separator: <!--more-->
---

![logo systemd reboot](/assets/img/posts/logo-systemd-reboot.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 


Para iniciar un rearranque completo se puede utilizar el comando `systemctl reboot`, pero ¿cómo puedo programarlo a una hora determinada?. En este apunte explico cómo hacerlo utilizando [systemd](https://systemd.io/), el gestor de arranque y administración para distribuciones Linux. 

Entre los ***servicios de timer de systemd*** hay una funcionalidad poco conocida que permite programar un reboot automático cuando queramos. 

<br clear="left"/>
<!--more-->

### Timer para reboot diario

Creo un fichero `reboot-diario.timer` donde pido la ejecución de una de las ***Unidades Especiales de Systemd***, en concreto la ***Unit "reboot.target"***, que permite hacer un shutdown y reboot de mi equipo Linux. 

* Fichero `/etc/systemd/system/reboot-diario.timer`

```console
[Unit]
Description=Reboot Diario.

[Timer]
OnCalendar=*-*-* 04:30:00
Unit=reboot.target

[Install]
WantedBy=timers.target
```

* Activo el nuevo servicio

```console
systemctl daemon-reload
systemctl enable reboot-diario.timer
systemctl start reboot-diario.timer
```

A partir de ahora mi equipo hará un reboot todos los días a las `04:30 am`.

<br/>

#### systemd.special

Algunas unidades son tratadas especialmente por systemd. Muchas de ellas tienen semántica interna especial y no pueden renombrarse, mientras que otras simplemente tienen un significado estándar y deberían estar presentes en todos los sistemas.

Existen bajo [systemd.special](https://man7.org/linux/man-pages/man7/systemd.special.7.html) y puedes consumirlas cuando lo necesites. Dejo aquí la explicación sobre la que uso en este ejemplo: 

* reboot.target

Es un target especial para apagar y reiniciar el sistema. Las aplicaciones que deseen reiniciar el sistema no deben usarla, sino que deben ejecutar `systemctl reboot` (posiblemente con la opción --no-block) o llamar a [systemd-logind(8)](https://man7.org/linux/man-pages/man8/systemd-logind.8.html)'s org.freedesktop.login1.Manager.Reboot() D-Bus directamente.

Recomiendo investigar también el servicio [systemd-reboot.service(8)](https://man7.org/linux/man-pages/man8/systemd-reboot.service.8.html) para más detalles de la operación que este target realiza.

Esta unidad tiene un alias llamado `runlevel6.target` por compatibilidad con SysV.
