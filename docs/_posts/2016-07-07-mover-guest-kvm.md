---
title: "Mover guest KVM"
date: "2016-07-07"
categories: virtualización
tags: backup iscsi kvm linux
excerpt_separator: <!--more-->
---

![Logo Mover](/assets/img/original/logo-move.svg){: width="150px" style="float:left; padding-right:25px" } 

Hace poco he tenido que mover una máquina virtual desde uno de mis servidores a otro en la misma red. Como siempre me he ayudado de google, aunque es una operación sencilla casi todo lo hago desde la shell, así que aquí dejo el proceso para acordarme...

<br clear="left"/>
<!--more-->

Para mover un Guest KVM a un nuevo Host:

- Copiar el disco VM desde el servidor fuente al destino.

```bash
# scp /home/luis/aplicacionix.qcow2 nuevo.parchis.org:/home/luis
```

- En el Fuente exportar el fichero de configuracion y copiarlo al destino

```bash
# virsh dumpxml aplicacionix > dom_aplicacionix.xml
# scp dom_aplicacionix.xml nuevo.parchis.org:/home/luis
```

- En el destino importar y añadir el fichero XML

```bash
# virsh define dom_aplicacionix.xml
```

- Arrancar la nueva VM manualmente o desde virt-manager
