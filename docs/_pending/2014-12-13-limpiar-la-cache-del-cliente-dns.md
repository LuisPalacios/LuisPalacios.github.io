---
title: "Limpiar la caché del cliente DNS"
date: "2014-12-13"
categories: 
  - "apuntes"
tags: 
  - "cache"
  - "dns"
---

[![dominios](https://www.luispa.com/wp-content/uploads/2014/12/dominios-150x150.png)](https://www.luispa.com/wp-content/uploads/2014/12/dominios.png)

Aunque esto mismo está ya muy trillado y documentado por internet, necesitaba tenerlo "cerca" y a mano, así que dejo un copia de lo que encontrarás por varias fuentes...

Todo "cliente" mantiene en el sistema operativo una caché donde guarda los nombres de dominio (DNS) según los va aprendiendo. Ahora bien, esta característica podría darnos la falsa impresión de que tenemos una dirección IP correcta cuando en realidad el equipo nos está entregando la dirección que tiene guardada (y podría ser que el servidor la haya cambiado).

Aunque pocas, hay situaciones donde necesitamos limpiar dicha "caché" pero no todos los sistemas operativos usan el mismo comando, así que ahí va una lista. Todos deben ejecutarse como administrador o root.

**Linux** - Hay varios proyectos que implementan un cliente DNS, así que depende, será uno de estos:

 
/etc/init.d/named restart
/etc/init.d/nscd restart
/etc/init.d/dnsmasq restart
 

**OSX** 10.10

 
\_\_\_Limpiar la Cache MDNS\_\_\_
discoveryutil mdnsflushcache
 
\_\_\_Limpiar la Cache UDNS\_\_\_
discoveryutil udnsflushcaches
 

**OSX** 10.9

 
dscacheutil -flushcache && killall -HUP mDNSResponder
 

**OSX** 10.7 – 10.8

 
killall -HUP mDNSResponder
 

**OSX** 10.5 – 10.6

 
dscacheutil -flushcache
 

**Windows o Windows Server**

 
ipconfig /flushdns
