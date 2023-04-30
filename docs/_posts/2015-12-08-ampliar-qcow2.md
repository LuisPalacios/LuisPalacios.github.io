---
title: "Ampliar disco qcow2"
date: "2015-12-08"
categories: virtualización
tags: convertir iscsi qcow2 disco tamaño
excerpt_separator: <!--more-->
---


![logo qcow2](/assets/img/posts/logo-qcow2.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 

En este apunte describo cómo ampliar el disco duro de una máquina virtual (VM) qcow2 (KVM). En el ejemplo voy a ampliar el disco duro de 10GB de mi VM **cortafuegix** a 15GB. 

<br clear="left"/>
<!--more-->

#### Estrategia

Antes de empezar voy a averiguar o confirmar el tamaño actual de la VM, me conecto con ella y ejecuto el comando `df -h`, que en mi caso informa de una capacidad de 10GB. 

- Averiguo el tamaño actual de la VM (cortafuegix)

```console
luis @ idefix ➜  ~  ssh -Y -a luis@cortafuegix.tudominio.com
luis@cortafuegix ~ $ sudo fdisk --list
Disco /dev/vda: 10 GiB, 10737418240 bytes, 20971520 sectores
Unidades: sectores de 1 * 512 = 512 bytes
Tamaño de sector (lógico/físico): 512 bytes / 512 bytes
Tamaño de E/S (mínimo/óptimo): 512 bytes / 512 bytes
Tipo de etiqueta de disco: gpt
Identificador del disco: DFA5DB69-5DA5-4AAB-8C4F-0266592CFB48
```

{% include showImagen.html
    src="/assets/img/posts/qcow2-1.png"
    caption="Estrategia de redimensionamiento"
    width="550px"
    %}

<br/>

#### Acciones en el Host 

La VM `cortafuegix` está alojada en el HOST `marte`, un equipo Linux con QEMU/KVM, así que conecto con él y continúo desde ahí: 

- Paro la VM (cortafuegix)

```console
luis@marte:~$ sudo virsh list
 Id   Name                      State
-----------------------------------------
 1    apps.tudominio.com          running
 2    tv.tudominio.com            running
 3    www.luispa.com            running
 4    UmbrellaForwarderVAHA     running
 5    UmbrellaForwarderVA       running
 6    cortafuegix.tudominio.com   running

luis@marte ~$ sudo virsh shutdown cortafuegix.tudominio.com
Domain cortafuegix.tudominio.com is being shutdown

```

{% include showImagen.html
    src="/assets/img/posts/qcow2-2.png"
    caption="Estado de las VMs"
    width="550px"
    %}


- Hago propietario del fichero a mi usuario para trabajar más cómodo.

```console
luis@tierra:~$ ls -al cortafuegix.tudominio.com.*
-rw-r--r-- 1 libvirt-qemu kvm  21448556544 may 27 09:22 cortafuegix.tudominio.com.qcow2
-rw-r--r-- 1 luis         luis        4975 abr  9  2017 cortafuegix.tudominio.com.xml

luis@marte ~$ sudo chown luis:luis /home/luis/cortafuegix.tudominio.com.qcow2
```
    
- Convierto `QCOW2` a `RAW` (tarda ~ 1min 15seg) - **Paso 1** en el gráfico.
    
```console
luis@marte:~$ qemu-img convert cortafuegix.tudominio.com.qcow2 -O raw cortafuegix.tudominio.com.raw
```

- Creo un archivo RAW de 5GB (tarda ~ 20seg)
    
```console
luis@marte ~$ dd if=/dev/zero of=extra5GBzeros.raw bs=1024k count=5120
```
    
- Combino ambos RAWs creo un RAW final de 15GB. **Paso 2** en el gráfico.
    
```console
luis@marte ~$ cat cortafuegix.tudominio.com.raw extra5GBzeros.raw > cortafuegix.tudominio.com.15GB.raw
```

- Hago un **backup del original QCOW2**
  
```console
luis@marte ~ $ mv cortafuegix.tudominio.com.qcow2 cortafuegix.tudominio.com.BACKUP.qcow2
```
    
- Convierto el RAW de 15GB a formato QCOW2 (tarda ~1min 34seg). **Paso 3** del gráfico.

```console
luis@marte ~$ qemu-img convert cortafuegix.tudominio.com.15GB.raw -O qcow2 cortafuegix.tudominio.com.qcow2
```

- Vuelvo a hacer propietario a qemu.

```console
luis@marte ~$ sudo chown libvirt-qemu:kvm /home/luis/cortafuegix.tudominio.com.qcow2
```

Arranco la VM de nuevo. 

```console
luis@marte ~$ sudo virsh start cortafuegix.tudominio.com
Domain cortafuegix.tudominio.com started
```

<br/>

#### Acciones en la máquina virtual

Ahora que ya tengo la VM arrancada voy a conectar con ella (`cortafuegix`) y utilizar `gparted` para ampliar la partición (**Paso 4** del gráfico). La máquina virtual arrancará sin problemas con una partición de 10GB dentro de un disco de 15GB por lo que podremos emplear esta herramienta para ampliarla. 

- Si me aparece el siguiente mensaje pulso en `Corregir`

{% include showImagen.html
    src="/assets/img/posts/qcow2-3.png"
    caption="Pulso en 'Corregir'"
    width="400px"
    %}


```console
luis @ idefix ➜  ~  ssh -Y -a luis@cortafuegix.tudominio.com
+------------------+
| Bienvenido Luis! |
+------------------+
luis@cortafuegix ~ $ sudo gparted
```

Selecciono el área existente, botón derecho, Redimensionar y extiendo el tamaño de la partición hacia la derecha para coger todo el espacio libre disponible. 

{% include showImagen.html
    src="/assets/img/posts/qcow2-4.png"
    caption="Proceso de redimensionamiento"
    width="400px"
    %}

Aplico los cambios, salgo de `gparted` y rearranco `cortafuegix`. Cuando conecte con él podré comprobar el nuevo tamaño.

```console
cortafuegix ~ # fdisk --list
Disco /dev/vda: 15 GiB, 5368709120 bytes, 10485760 sectores
```
