---
title: "HFS+ en Linux"
date: "2012-12-15"
categories: linux
tags: hfs linux gentoo
excerpt_separator: <!--more-->
---

![HFS+](/assets/img/posts/logo-hfsplus.png){: width="150px" height="150px" style="float:left; padding-right:25px" } 

HFS+ (Hierarchical File System Plus), también conocido como MacOS Plus, es el formato usado por defecto en la partición donde está instalado el sistema operativo MacOS de Apple. Fué lanzado como una mejora del HFS original en el año 1998 e introducido en el sistema operativo macOS desde su versión 8.1


<br clear="left"/>
<!--more-->

Para dar soporte a un filesystem de tipo HFS+ en linux es necesario configurar de forma adecuada el kernel.

```
  File systems ---> 
   [*] Miscellaneous filesystems --->
      <*> Apple Macintosh file system support
      <*> Apple Extended HFS file system support
```

Compilar, instalar y rearrancar el equipo. En mi caso tenía un disco externo FireWire con partición HFS+ creada en un antiguo iMac. He conectado este disco [FireWire externo a mi Mac Mini]({% post_url 2012-11-15-firewire-en-gentoo %}) y ahora puedo acceder a sus datos al soportar HFS+ en Gentoo linux. Este es el aspecto de la tabla de particiones (visto con gparted)

{% include showImagen.html 
      src="/assets/img/original/capturadepantalla2013-11-15alas11.37.17_0_o.png" 
      caption="Programa GParted" 
      width="730px"
      %}

Creo el punto de montaje y configuro el fichero /etc/fstab

```
# mkdir /mnt/despensa
# cat /etc/fstab
:
/dev/sdc3 /mnt/despensa hfsplus noauto,rw,exec,users,noatime 0 0
:
```


A partir de aquí ya puedo acceder a los datos

``` 
# mount /mnt/despensa
```

**OJO!, SOLO EN LECTURA!!**. Es decir, tenemos un problema, por desgracia el soporte en linux de particiones HFS+ con registro (o con Journaling) no está soportado así que la partición se ha montado en modo "Read Only"

A partir de este momento ya puedo acceder a los datos SOLO EN LECTURA, lo cual suele ser un problema :)

``` 
# mount
:
/dev/sdc3 on /mnt/despensa type hfsplus (ro,noatime,noexec,nosuid,nodev)
```

Posible solución: eliminar el Journaling. En mi caso sí es aceptable, dado que no voy a conectar este disco nunca más a un MacOSX.

Veamos cómo **eliminar el registro (journaling) de una partición HFS+ desde linux**: Puedes usar el siguiente programa en C, lo compilas y ejecutas como root. Aquí tienes todo el proceso. Copia y pega lo siguiente en un archivo con nombre **disable_journal.c**

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <byteswap.h>

int main(int argc, char *argv[])
{
 int fd = open(argv[1], O_RDWR);
 if(fd < 0) {
   perror("open");
   return -1;
 }
 
 unsigned char *buffer = (unsigned char *)mmap(NULL, 2048, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
 if(buffer == (unsigned char*)0xffffffff) {
    perror("mmap");
    return -1;
 }
 
 if((buffer[1024] != 'H') && (buffer[1025] != '+')) {
  fprintf(stderr, "%s: HFS+ signature not found -- aborting.\n", argv[0]);
  return -1;
 }
 
 unsigned long attributes = *(unsigned long *)(&buffer[1028]);
 attributes = bswap_32(attributes);
 printf("attributes = 0x%8.8lx\n", attributes);
 
 if(!(attributes & 0x00002000)) {
  printf("kHFSVolumeJournaledBit not currently set in the volume attributes field.\n");
 }
 
 attributes &= 0xffffdfff;
 attributes = bswap_32(attributes);
 *(unsigned long *)(&buffer[1028]) = attributes;
 
 buffer[1032] = '1';
 buffer[1033] = '0';
 buffer[1034] = '.';
 buffer[1035] = '0';
 
 buffer[1036] = 0;
 buffer[1037] = 0;
 buffer[1038] = 0;
 buffer[1039] = 0;
 
 printf("journal has been disabled.\n");
 return 0;
}
```

#### Compilo y ejecuto el programa

```
make disable_journal
:
disable_journal /dev/sdc3
:
journal has been disabled.
```

El último paso es hacer un "File System check". Necesitas instalar sys-fs/diskdev_cmds que incorpora tanto fsck.hfsplus (para comprobar una partición HFS+) como mkfs.hfsplus (para crear una partición HFS+)
 
```bash
emerge -v diskdev_cmds
fsck /dev/sdc3
```

A partir de este momento ya puedo acceder a los datos en LECTURA/ESCRITURA

 
```zsh
mount /mnt/despensa
mount
:
/dev/sdc3 on /mnt/despensa type hfsplus (**rw**,noatime,noexec,nosuid,nodev)
```

