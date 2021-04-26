---
title: "Mover guest KVM"
date: "2016-07-07"
categories: 
  - "apuntes"
---

Para mover un Guest KVM a un nuevo Host:

- Copiar el disco VM desde el servidor fuente al destino.

\# scp /home/luis/aplicacionix.qcow2 nuevo.parchis.org:/home/luis

- En el Fuente exportar el fichero de configuracion y copiarlo al destino

\# virsh dumpxml aplicacionix > dom\_aplicacionix.xml
# scp dom\_aplicacionix.xml nuevo.parchis.org:/home/luis

- En el destino importar y añadir el fichero XML

\# virsh define dom\_aplicacionix.xml

- Arrancar la nueva VM manualmente o desde virt-manager
