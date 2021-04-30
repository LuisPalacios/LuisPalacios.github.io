---
title: "Monitorizar procesos con htop en Linux"
date: "2014-12-30"
categories: gentoo
tags: htop linux top
excerpt_separator: <!--more-->
---

![htop-1.0-screenshot](/assets/img/original/htop-1.0-screenshot.png){: width="730px" padding:10px }htop** es un programa que visualiza los procesos de linux y permite interactuar con ellos, es una aplicación de "texto" que sustituye a "top" cuando queremos hacer un análisis más detallado.

Para instalarlo en Gentoo primero añado lo siguiente al kernel de linux y después instalo 'lsof' y 'htop':

* CONFIG_TASKSTATS = yes
* CONFIG_TASK_XACCT = yes
* CONFIG_TASK_IO_ACCOUNTING = yes

 
emerge -v lsof htop
