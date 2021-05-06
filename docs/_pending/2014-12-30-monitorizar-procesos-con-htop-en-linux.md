---
title: "Monitorizar procesos con htop en Linux"
date: "2014-12-30"
categories: gentoo
tags: htop linux top
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/htop-1.0-screenshot.png"
    caption="htop-1.0-screenshot"
    width="600px"
    %}

Para instalarlo en Gentoo primero añado lo siguiente al kernel de linux y después instalo 'lsof' y 'htop':

* CONFIG_TASKSTATS = yes
* CONFIG_TASK_XACCT = yes
* CONFIG_TASK_IO_ACCOUNTING = yes

 
emerge -v lsof htop
