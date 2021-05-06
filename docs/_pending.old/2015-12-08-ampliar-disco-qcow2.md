---
title: "Ampliar disco qcow2"
date: "2015-12-08"
categories: apuntes
tags: convertir iscsi qcow2
excerpt_separator: <!--more-->
---

En este apunte describo cómo ampliar el disco duro de una máquina virtual (VM) qcow2 (KVM).

![qcow2grow](/assets/img/original/qcow2grow-1024x779.png){: width="730px" padding:10px }

En este ejemplo la VM **cortafuegix** ocupa 10GB (se averigua arrancándola y ejecutando el comando df) y necesito ampliarla a 15GB. Seguimos los pasos siguientes:  

### Acciones en el Host KVM (luna)

- Paro la VM (cortafuegix)
    
    luis@marte ~$ sudo virsh shutdown cortafuegix
    
- Hago propietario del fichero a mi usuario para trabajar más cómodo.

luis@marte ~$ sudo clown luis:luis cortafuegix.qcow2

- Hago un backup del original (tarda ~ 1min 5seg)
    
    luis@marte ~ $ cp cortafuegix.qcow2 cortafuegix-BACKUP.qcow2
    
- Convierto el fichero cortafuegix.qcow2 a RAW (tarda ~ 1min 15seg) - **Paso 1** en el gráfico.
    
    luis@marte ~ $ qemu-img convert cortafuegix.qcow2 -O raw cortafuegix.raw
    
- Creo un archivo RAW de 5GB (tarda ~ 20seg)
    
    luis@marte ~$ dd if=/dev/zero of=extra5GBzeros.raw bs=1024k count=5120
    
- Con ambos RAWs creo un RAW final de 15GB. **Paso 2** en el gráfico.
    
    luis@marte ~$ cat cortafuegix.raw extra5GBzeros.raw > cortafuegix15GB.raw
    
- Convierto el RAW de 15GB a formato QCOW2 (tarda ~1min 34seg). **Paso 3** del gráfico.

luis@marte ~$ qemu-img convert cortafuegix15GB.raw -O qcow2 cortaguegix.qcow2

- Vuelvo a hacer propietario a qemu.

luis@marte ~$ sudo chown qemu:qemu cortafuegix.qcow2

-  Arrancamos la VM y utilizo GPARTED para ampliar la partición (**Paso 4** del gráfico). Nota: La máquina virtual arrancará sin problemas con una partición de 10GB dentro de un disco de 15GB por lo que podremos emplear gparted para ampliarla.
