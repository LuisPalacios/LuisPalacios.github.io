---
title: "Linux: backup de disco físico a fichero"
date: "2015-03-28"
categories: apuntes gentoo
tags: backup disco imagen linux
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/Hdd-1024x419.png"
    caption="Hdd"
    width="600px"
    %}

Hace no mucho tuve que hacer un backup completo del disco duro de mi **Servidor** para instalar otro sistema operativo y opté por clonar el disco duro de arranque completo en un fichero comprimido (imagen byte a byte: **servidor.img.gz**). En caso de desastre (con el nuevo sistema operativo) podría fácilmente dar marcha atrás. Es un proceso sencillo pero siempre tardo un buen rato en encontrar en internet cómo hacerlo, así que he decidido documentarlo. Además añado un "extra", cómo montar la partición root dentro de dicha imagen para consultar ciertas cosas. Todo esto se consigue con estas herramientas:

- Copia byte a byte: dd
- Comprimir: gzip
- Guardar información sobre las particiones: fdisk
    

 

## Backup /dev/sdX a fichero imagen (.img)

Es imposible hacer un backup del mismo disco con el que he arrancado el equipo, así que lo primero es hacer boot con un LiveCD Linux. Después de arrancar averiguamos el nombre de device del disco fuente (en mi caso el disco duro de arranque es **/dev/sdb**). Decido salvar tres ficheros: el MBR, el disco completo y la información sobre las paticiones. Notar que el importante es el "disco completo", los otros dos podrías obviarlos.

# dd if=/dev/sdb of=servidor_mbr.img bs=512 count=1
# dd if=/dev/sdb conv=sync,noerror bs=64K | gzip -c > servidor.img.gz
# fdisk -l /dev/sda > servidor.fdiskinfo

 

## Restaurar desde fichero (.img) a /dev/sdX

Si hubiese tenido un desastre con la instalación del nuevo sistema operativo simplemente tengo que restaurar la imagen salvada, así que vuelvo a arrancar con el LiveCD, reconocería el disco como "sdb" y ejecutaría lo siguiente para recuperar los datos:

# gunzip -c servidor.img.gz | dd of=/dev/sdb

 

## Extraer una patición del fichero .img

Este es el extra que comentaba. Imaginemos que lo único que necesito es acceder a consultar datos de mi antiguo disco duro. Resulta que tenemos todo dentro de una única imagen y encima comprimida, así que lo primero que debes hacer es descomprimir la imagen.

# gunzip -c servidor.img.gz | dd of=servidor.img
# ls -al
:
-rwxr-xr-x 1 root root 240057450496 mar 28 18:19 servidor.img

Ya tengo una imagen byte a byte del disco original (incluye su MBR, tabla de particiones y las particiones en sí). Para acceder a una partición concreta dentro de servidor.img necesito saber en que "byte" empieza y termina dicha partición, muestro dos formas de harcelo:

 

### Opción .fdiskinfo

Utilizo la información de fdisk que salvé (en un fichero que llamé servidor.fdiskinfo) al hacer backup. Cuando consulto dicha información observo que los datos están en bloques de 512bytes, así que usaré este tipo de unidad cuando ejecute el comando dd. Lo que necesito saber es donde debo empezr (skip) y cuantos bloiques extraer (count).

Obtengo la información desde el fichero .fdiskinfo:

# cat servidor.fdiskinfo
Disk /dev/sda: 223.6 GiB, 240057409536 bytes, 468862128 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 216D00BC-0D91-4863-80A0-6654F6DD19D4

Device           Start          End   Size Type
/dev/sda1         2048         6143     2M BIOS boot partition
/dev/sda2         6144       268287   128M Microsoft basic data
/dev/sda3       268288      1316863   512M Microsoft basic data
/dev/sda4      1316864    468860079   223G Microsoft basic data

Notar que cuando guardé esta información se usan unidades de 512 bytes (Units:). La información que me interesa es la siguiente:

- skip = fdisk start = 1316864
- count = fdisk end-start = 468860079 - 1316864 + 1 = 467543216

Con esos datos puedo extraer el file system usando el comando dd indicando dónde empezar y cuanto copiar (en este caso indico dicha información en unidades de 512 bytes)

# dd if=servidor.img of=servidor_root.iso bs=512 skip=1316864 count=467543216
467543216+0 records in
467543216+0 records out
239382126592 bytes transferred in 5379.810398 secs (44496387 bytes/sec)

# mkdir /mnt/servidor_root
# mount -o loop servidor_root.iso /mnt/servidor_root

 

### Opción fdisk/parted

Siempre puedes usar fdisk o parted para mostrar la información de las particiones desde el fichero imagen (es decir, no necesitas salvar o tener la información guardada).

Opción fdisk

# fdisk -l servidor.img
GPT PMBR size mismatch (468862127 != 468862207) will be corrected by w(rite).

Disco totobo.iso: 223,6 GiB, 240057450496 bytes, 468862208 sectores
Unidades: sectores de 1 * 512 = 512 bytes
Tamaño de sector (lógico/físico): 512 bytes / 512 bytes
Tamaño de E/S (mínimo/óptimo): 512 bytes / 512 bytes
Tipo de etiqueta de disco: gpt
Identificador del disco: 216D00BC-0D91-4863-80A0-6654F6DD19D4

Device        Start       End   Sectors  Size Type
totobo.iso1    2048      6143      4096    2M BIOS boot
totobo.iso2    6144    268287    262144  128M Microsoft basic data
totobo.iso3  268288   1316863   1048576  512M Microsoft basic data
totobo.iso4 1316864 468860079 467543216  223G Microsoft basic data

Obtengo la siguiente información (una vez más en unidades de 512 bytes):

- skip = 1316864
- count = 467543216

Opción parted

# parted servidor.img
:
(parted) unit B
(parted) print
Aviso: Not all of the space available to servidor.img appears to be used, you can fix the GPT to use all of the space (an extra 80 blocks) or continue
with the current setting?
Arreglar/Fix/Descartar/Ignore? Ignore
Model:  (file)
Disk servidor.iso: 240057450496B
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Numero  Inicio      Fin            Tamaño         Sistema de ficheros  Nombre  Banderas
 1      1048576B    3145727B       2097152B                            grub    bios_grub
 2      3145728B    137363455B     134217728B     ext2                 boot    msftdata
 3      137363456B  674234367B     536870912B     linux-swap(v1)       swap    msftdata
 4      674234368B  240056360959B  239382126592B  ext4                 rootfs  msftdata

Obtengo la siguiente información pero esta vez en Bytes, así que lo convierto a bloques de 512, obviamente el resultado es el mismo que antes.

- skip = 674234368/512 = 1316864
- count = 239382126592/512 = 467543216

La extracción del file system y su posterior montaje es idéntico a como hicimos la vez anterior.

# dd if=servidor.img of=servidor_root.iso bs=512 skip=1316864 count=467543216
467543216+0 records in
467543216+0 records out
239382126592 bytes transferred in 5379.810398 secs (44496387 bytes/sec)

# mkdir /mnt/servidor_root
# mount -o loop servidor_root.iso /mnt/servidor_root
