---
title: "Monitorizar procesos con htop en Linux"
date: "2014-12-30"
categories: 
  - "gentoo"
tags: 
  - "htop"
  - "linux"
  - "top"
---

**[![htop-1.0-screenshot](https://www.luispa.com/wp-content/uploads/2014/12/htop-1.0-screenshot.png)](https://www.luispa.com/wp-content/uploads/2014/12/htop-1.0-screenshot.png)htop** es un programa que visualiza los procesos de linux y permite interactuar con ellos, es una aplicación de "texto" que sustituye a "top" cuando queremos hacer un análisis más detallado.

Para instalarlo en Gentoo primero añado lo siguiente al kernel de linux y después instalo 'lsof' y 'htop':

\* CONFIG\_TASKSTATS = yes
\* CONFIG\_TASK\_XACCT = yes
\* CONFIG\_TASK\_IO\_ACCOUNTING = yes

 
emerge -v lsof htop
