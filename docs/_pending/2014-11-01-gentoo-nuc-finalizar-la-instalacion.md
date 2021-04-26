---
title: "Gentoo en NUC: Finalizar la instalación"
date: "2014-11-01"
categories: 
  - "gentoo"
tags: 
  - "linux"
  - "nuc"
---

[![metas2](https://www.luispa.com/wp-content/uploads/2014/12/metas2.jpg)](https://www.luispa.com/wp-content/uploads/2014/12/metas2.jpg)

Este post pertenece a la colección sobre la [instalación de Gentoo GNU/Linux en un Intel® NUC D54250WYK](https://www.luispa.com/?p=7). Este es el último apunte de la serie donde describo cuales son los últimos retoques a realizar para dar por terminada la instalación.

**Completar la instalación**

Ya hemos terminado los [pasos necesarios antes del primer "reboot"](https://www.luispa.com/?p=842), arranca desde el disco duro SSD,. Cuando tengas el prompt y hagas login por primera vez podrás observar qué módulos se han cargado por defecto:

 
 
totobo ~ # lsmod
Module Size Used by
usbhid 30803 0
snd\_hda\_intel 15332 0
snd\_hda\_controller 16221 1 snd\_hda\_intel
snd\_hda\_codec 73489 2 snd\_hda\_intel,snd\_hda\_controller
snd\_hwdep 5405 1 snd\_hda\_codec
xhci\_hcd 90185 0
ehci\_pci 3256 0
ehci\_hcd 35032 1 ehci\_pci
snd\_pcm 62259 3 snd\_hda\_codec,snd\_hda\_intel,snd\_hda\_controller
e1000e 138496 0
x86\_pkg\_temp\_thermal 4285 0
snd\_timer 15341 1 snd\_pcm
coretemp 5116 0
usbcore 138617 4 ehci\_hcd,ehci\_pci,usbhid,xhci\_hcd
snd 48425 5 snd\_hwdep,snd\_timer,snd\_pcm,snd\_hda\_codec,snd\_hda\_intel
i2c\_i801 8461 0
usb\_common 1480 1 usbcore
 

La Red

Ahora toca configurar la red. El manual oficinal de instalación de Gentoo propone configurar la red antes de hacer el primer boot,  en mi caso lo he dejado para el final y la razón es muy sencilla: "udev".

A fecha (Nov'2014) he decidido crear un sistema "libre de systemd" y por lo tanto opto por el fork de Gentoo llamado "eudev", que no es otra cosa que un udev sin ningún tipo de vínculo con systemd. ¿Porqué? bueno, basta con buscar "systemd linus torvals" en google, está claro que todavía queda tiempo para que los ánimos se calmen.

Tras el bloqueo a systemd/udev y el upgrade que hice con "emerge" el sistema queda listo para usar eudev y tras el primer boot observamos que eudev mantiene el nombre de toda la vida (eth0) al interfaz de red, en vez de usar un "predictable network interface name".

Cuando terminamos de arrancar por primera vez podemos ver qué ha detectado el sistema con:

 
 
totobo ~ # idmesg | grep -i e1000e
\[ 2.020471\] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
\[ 2.020475\] e1000e: Copyright(c) 1999 - 2014 Intel Corporation.
\[ 2.020640\] e1000e 0000:00:19.0: Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
\[ 2.020662\] e1000e 0000:00:19.0: irq 58 for MSI/MSI-X
\[ 2.443707\] e1000e 0000:00:19.0 eth0: registered PHC clock
\[ 2.443713\] e1000e 0000:00:19.0 eth0: (PCI Express:2.5GT/s:Width x1) c0:3f:d5:65:2e:75
\[ 2.443716\] e1000e 0000:00:19.0 eth0: Intel(R) PRO/1000 Network Connection
\[ 2.443757\] e1000e 0000:00:19.0 eth0: MAC: 11, PHY: 12, PBA No: FFFFFF-0FF
\[ 294.748405\] e1000e 0000:00:19.0: irq 58 for MSI/MSI-X

Confirmar que el "kernel" sí tiene listo el interfaz (importante la opción -a)

totobo ~ # ifconfig -a
eth0: flags=4098<BROADCAST,MULTICAST> mtu 1500
ether c0:3f:d5:65:2e:75 txqueuelen 1000 (Ethernet)
RX packets 0 bytes 0 (0.0 B)
RX errors 0 dropped 0 overruns 0 frame 0
TX packets 0 bytes 0 (0.0 B)
TX errors 0 dropped 0 overruns 0 carrier 0 collisions 0
device interrupt 20 memory 0xf7c00000-f7c20000
:
 

Así pues, hago una primera configuración muy básica para "tener red", que consiste en activar tcp/ip:

- Con cliente DHCP

config\_eth0="dhcp"
mtu\_eth0="8704" # Usa esto si tienes un switch que soporte y tenga configurado jumbo frames
 

- Con IP Fija

 
config\_eth0="192.168.1.245/24"
routes\_eth0="default via 192.168.1.1"
mtu\_eth0="8704"     # Usa esto si tienes un switch que soporte y tenga configurado jumbo frames
 

 
domain parchis.org
nameserver 192.168.1.1
 

Crear net.eth0 y activarlo

 
 
:
totobo ~ # cd /etc/init.d
totobo init.d # ln -s net.lo net.eth0
totobo init.d # /etc/init.d/net.eth0 start
totobo init.d # rc-update add net.eth0 default
:
totobo init.d # ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST> mtu 1500
inet 192.168.1.245 netmask 255.255.255.0 broadcast 192.168.1.255
ether c0:3f:d5:65:2e:75 txqueuelen 1000 (Ethernet)
RX packets 880 bytes 79761 (77.8 KiB)
RX errors 0 dropped 14 overruns 0 frame 0
TX packets 426 bytes 69281 (67.6 KiB)
TX errors 0 dropped 0 overruns 0 carrier 0 collisions 0
device interrupt 20 memory 0xf7c00000-f7c2000
 

Con esta configuración tan básica puedo empezar a trabajar, ya iré mejorando la parte de red del equipo.

Usuario normal

Recomiendo crear un usuario con el que hacer login y trabajar de forma normal en el equipo, en mi caso:

 
 
totobo ~ # groupadd -g 1450 luis
totobo ~ # useradd -u 1450 -g luis -m -G cron,audio,cdrom,cdrw,users,wheel -d /home/luis -s /bin/bash luis
totobo ~ # passwd luis
 

Limpiar tarballs

 
 
# rm /stage3-\*.tar.bz2\*
# rm /portage-\*.tar.bz2\*
 

Terminar la instalación

Para terminar me gusta acelerar al máximo el arranque del equipo, así que voy a activar Fast Boot en la BIOS (recuerda, se entra pulsando F2 durante el arranque) y además voy a poner a '0' el tiempo de espera de GRUB:

Modificar GRUB\_TIMEOUT=0 en /etc/default/grub

 
 
# mount /grub
# grub2-mkconfig -o /boot/grub/grub.cfg
 

Y con esto termino, espero que sea de ayuda esta guía complementaria al manual de Gentoo para configurar un NUC D54250WYK.

Paquetes "must have"

Aunque no voy a documentar como se parametrizan todos... sí que dejo aquí una lista de los paquetes que he ido añadiendo al equipo, bien porque son imprescindibles como "servidor casero y router hacia internet" o bien porque empleo esporádicamente:

- app-portage/genlop
- app-portage/eix
- sys-apps/pciutils
- sys-block/gparted
- x11-apps/xclock
- virtual/emacs-24          $HOME/.emacs
- app-admin/sudo
- net-misc/dhcp
- net-dns/bind
- net-misc/wget
- net-firewall/iptables
- sys-apps/iproute2
- net-analyzer/wireshark
- net-analyzer/bmon
- net-analyzer/tcpdump
- net-fs/nfs-utils
- app-emulation/docker     (Sobre Docker)
- dev-tcltk/expect         USE=doc para "autoexpect" (se instala en /usr/share/doc/expect-x.yy/examples/)

Se acabó, terminamos la instalación del NUC!!!.  Nota: Si lo deseas puedes volver al paso anterior: [antes del primer reboot del kernel](https://www.luispa.com/?p=842)
