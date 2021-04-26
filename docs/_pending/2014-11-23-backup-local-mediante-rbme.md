---
title: "RBME: Backup incremental en Linux"
date: "2014-11-23"
categories: 
  - "gentoo"
tags: 
  - "linux"
---

En este artículo explico el metodo que uso para hacer backup de mis datos persistentes de mi servidor Linux a un disco externo. La técnica está basada en Rsync y backups [incrementales usando Hard Links](http://earlruby.org/2013/05/creating-differential-backups-with-hard-links-and-rsync/) mediante el script [RBME](https://github.com/schlomo/rbme) que facilita todo el proceso.

[![backup](https://www.luispa.com/wp-content/uploads/2014/12/backup-1024x830.png)](https://www.luispa.com/wp-content/uploads/2014/12/backup.png)

Voy a explicar dos "destinos físicos" de los backups, el primero es el obvio, usar un disco USB, pero el segundo es algo más ingenioso: emplear un disco iSCSI que reside en una NAS. En cualquier caso y para entender este apunte, quédate con los siguientes directorios que usaré como fuente (datos a salvar) y destino (ubicación donde los salvaré):

- /Apps --> Datos fuentes
- /mnt/Backup --> Destino del backup

Como habrás visto a lo largo de este blog, soy un fan de Gentoo, así que todos los comandos que ves aquí están relacionados con esta meta-distribución. Si usas cualquier otra no te será difícil adaptarlo.

 

## Instalación de RBME

Primero necesitamos el script, así que ejecuta los comandos siguientes para instalarlo.

cd /usr/bin
wget https://raw.githubusercontent.com/schlomo/rbme/master/rbme
chmod 755 rbme
cd /etc
wget https://raw.githubusercontent.com/schlomo/rbme/master/rbme.conf 

Para que funcione es necesario tener instalado un MTA smtp y procmail:

emerge -v ssmtp
chown root:mail /var/spool/mail/
chmod 03775 /var/spool/mail/
emerge -v procmail 

En mi caso me gusta cambiar una línea de este script para que el directorio también indique la hora en la que se hizo el backup. El ejecutable está en /usr/bin/rbme

:
#today="$(date "+%Y-%m-%d")"
today="$(date "+%Y-%m-%d\_%H-%M-%S")"
:

Las configuraciones las detallo en cada opción de disco.

 

## Backup a disco USB

La primera opción, usar un disco externo USB para hacer backup. También valdría que fuese 2.0 pero hoy en día no merece la pena.

[![usb](https://www.luispa.com/wp-content/uploads/2014/12/usb-300x162.png)](https://www.luispa.com/wp-content/uploads/2014/12/usb.png)

Utilizo un disco que ya tenía para otros menesteres y creo una partición de tipo EXT4 con el resto del espacio usando gparted.

[![gparted](https://www.luispa.com/wp-content/uploads/2014/12/gparted.png)](https://www.luispa.com/wp-content/uploads/2014/12/gparted.png)

El proceso es muy sencillo, conectamos el USB, entramos como root y ejecutamos gparted. Seleccionamos el espacio libre y creamos una partición de tipo ext4.

Añado la nueva partición al /etc/fstab para que se monte en /mnt/Backup.

/dev/sdb2  /mnt/Backup ext4  noatime  0 0

- Monto el file system y creo un fichero de control para poder usarlo en mi script.

marte ~ # mount /mnt/Backup
marte ~ # touch /mnt/Backup/.Disco\_Backup\_USB.txt

- Veamos la configuración que utilizo para este caso

Preparo el fichero de configuración de RBME /etc/rbme.conf Nota: Debes modificar y adaptar este fichero de configuración a tu caso concreto, este es solo un ejemplo.

BACKUP\_PATH="/mnt/Backup"
MIN\_FREE\_BEFORE\_HOST\_BACKUP="30000"
MIN\_INODES\_BEFORE\_HOST\_BACKUP="100000"
MIN\_FREE\_AFTER\_HOST\_BACKUP="40000"
MIN\_INODES\_AFTER\_HOST\_BACKUP="300000"
MIN\_KEEP\_OLD\_BACKUPS="30"
VERBOSE=${VERBOSE=}
STATISTICS="yes"
MAILTO="tusuario@tudominio.com"
MAILFROM="root@tuhost"
MAILSTYLE="all"
LOGFILE=$(date +"/var/log/$ME.log.%d")
RSYNC\_RSH="ssh -c blowfish-cbc”

Preparo un script /etc/cron.daily/rbme\_daily.sh para que se ejecute diariamente desde el cron. Nota que este es solo un ejemplo, debes adaptar el script a tu configuración de directorio(s) y nombres de servidor.

/rbme\_daily.sh"\]
#!/bin/bash
#
vm\_NAME="aplicacionix-file"
iSCSI\_SERVER="192.168.1.2"
TARGET="iqn.2004-04.com.qnap:ts-569pro:iscsi.backuprbme.d70ea1"

# mandar mensaje por correo
#
manda\_mensaje() {
    # Get the IP Address from first argument
    mensaje=$1
    {
        echo "From: Marte"
        echo "To: Luis Palacios"
        echo "Subject: Backup RBME"
        echo "Content-Type: text/plain; charset=UTF-8"
        echo ""
        echo "${1}"
    } | /usr/sbin/sendmail -f "root@marte" usuario@dominio.com
}

# Si la VM está arrancada la paro.
#
vm\_is\_on="0"
vm\_was\_on="0"
num="0"
while true; do

    # Check if VM is up and running, if so shut it down
    vm\_list=\`virsh list --all | grep -i aplicacionix-file\`
    aplicacionix\_name=\`echo ${vm\_list} | gawk '{print $2}'\`
    aplicacionix\_state=\`echo ${vm\_list} | gawk '{print $3}'\`
    echo ${aplicacionix\_name}
    echo ${aplicacionix\_state}
    if \[ "${aplicacionix\_state}" == "ejecutando" \]; then
        vm\_was\_on="1"
        vm\_is\_on="1"
        if \[ "${num}" == "3" \]; then
            break
        fi
        num=$((num+1))
        echo "La VM '${aplicacionix\_name}' esta ejecutandose, ejecuto su apagado (intento ${num})"
        virsh shutdown ${aplicacionix\_name}
        sleep 10
    else
        if \[ "${aplicacionix\_state}" == "apagado" \]; then
            vm\_is\_on="0"
            break
        fi
    fi
done

# Si no consigo pararla me piro
#
if \[ "${vm\_is\_on}" = "1" \]; then
    manda\_mensaje "He interrumpido el backup RBME porque no se ha podido parar la maquina virtual: ${aplicacionix\_name}"
    exit
fi

# Confirmo que tengo el directorio /mnt/Backup activo
#
found=\`iscsiadm -m session | grep -i ${TARGET}\`
if \[ "${found}" = "" \]; then
    echo "Login con el servidor iSCSI"
    iscsiadm -m node -T ${TARGET} -p ${iSCSI\_SERVER} --login
fi

wasMounted="no"
if \[ ! -f "/mnt/Backup/.Disco\_Backup\_iSCSI.txt" \];
then
    echo "Monto /mnt/Backup"
    mount /mnt/Backup
else
    wasMounted="yes"
fi

# Ejecuto el backup
#
if \[ -f "/mnt/Backup/.Disco\_Backup\_iSCSI.txt" \];
then
    echo "Backup desde /Apps a /mnt/Backup"
    rbme marte:/Apps
    #
    # Si no estaba originalmente montado pues lo vuelvo a desmontar
    if \[ "${wasMounted}" = "no" \]; then
        umount /mnt/Backup
    fi
fi

# Si la VM estaba arrancada la vuelvo a activar
#
if \[ "${vm\_was\_on}" = "1" \]; then
    echo "Arranco '${aplicacionix\_name}'"
    virsh start ${aplicacionix\_name}

    # La VM que estoy parando tiene mi servidor de correo asi que he creado 
    # un script para automandarme un mensaje dentro de un rato con el log
    # que genera el programa rbme
    sleep 90
    /root/priv/bin/manda\_mail.sh
fi

La VM que estoy parando tiene mi servidor de correo asi que he modificado el ejecutable rbme (añado la lína: cat "$LOGFILE" > /tmp/mandar.txt) y he creado un script para automandarme un mensaje al terminar el script anterior:

- /root/priv/bin/manda\_mail.sh"

<

pre> #!/bin/bash # if test /tmp/mandar.txt ; then { echo "From: Marte" echo "To: Luis Palacios" echo "Subject: Backup RBME" echo "Content-Type: text/plain; charset=UTF-8" echo "" cat /tmp/mandar.txt } | /usr/sbin/sendmail -f "root@marte" usuario@dominio.com fi

<

pre>

 

## Backup a disco iSCSI

Otra opción muy interesante es usar un disco remoto en una NAS a través de iSCSI. En mi caso tengo una NAS de QNAP, un [Hypervisor KVM](https://www.luispa.com/?p=3221) y mis máquinas virtuales ([un ejemplo](https://www.luispa.com/?p=3462)). Si mezclamos los ingredientes tenemos un caso de uso claro: entregar un espacio "físico" vía iSCSI desde la NAS al hypervisor, para que haga backups con RBME de los datos persistentes de las máquinas virtuales.

### Acciones en el QNAP

- Creo un espacio libre de 250GB en mi QNAP (NAS)

[![iSCSI-RBME-1](https://www.luispa.com/wp-content/uploads/2015/06/iSCSI-RBME-1-1024x595.png)](https://www.luispa.com/wp-content/uploads/2015/06/iSCSI-RBME-1.png)

[![iSCSI-RBME-2](https://www.luispa.com/wp-content/uploads/2015/06/iSCSI-RBME-2-1024x602.png)](https://www.luispa.com/wp-content/uploads/2015/06/iSCSI-RBME-2.png)

[![iSCSI-RBME-3](https://www.luispa.com/wp-content/uploads/2015/06/iSCSI-RBME-3-1024x602.png)](https://www.luispa.com/wp-content/uploads/2015/06/iSCSI-RBME-3.png)

[![iSCSI-RBME-4](https://www.luispa.com/wp-content/uploads/2015/06/iSCSI-RBME-4-1024x601.png)](https://www.luispa.com/wp-content/uploads/2015/06/iSCSI-RBME-4.png)

[![iSCSI-RBME-5](https://www.luispa.com/wp-content/uploads/2015/06/iSCSI-RBME-5-1024x591.png)](https://www.luispa.com/wp-content/uploads/2015/06/iSCSI-RBME-5.png)

- Me apunto el target: iqn.2004-04.com.qnap:ts-569pro:iscsi.backuprbme.d70ea1

 

### Acciones en el Linux donde ejecuto RBME

Como decía antes, estoy entregando un espacio "físico" vía iSCSI desde la NAS al hypervisor, para que haga backups con RBME de los datos persistentes de las máquinas virtuales. Esto significa que el Linux (hypervisor) tiene acceso a los datos persistentes que modifican sus VM's y tiene la capacidad de apagar las VM's, hacer backup y volver a arrancarlas, así que me ha parecido el sitio más adecuado.

\[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background\_color="#ffffff" border\_width="1" border\_color="#dddddd" \]

**NOTA**: En los comandos siguientes verás que aparece un segundo target con "vmgentoo" en su IQN, ignóralo porque no tiene nada que ver con el backup... es otro disco que uso para una de las máquinas virtuales ([este otro apunte](https://www.luispa.com/?p=3462)).

\[/dropshadowbox\]

- Para poder configurar discos iSCSI hay que hacer un discovery a ver que me ofrece el NAS

marte ~ # iscsiadm -m discovery --portal=192.168.1.2:3260 -t sendtargets
192.168.1.2:3260,1 iqn.2004-04.com.qnap:ts-569pro:iscsi.vmgentoo.d70ea1
192.168.1.2:3260,1 iqn.2004-04.com.qnap:ts-569pro:iscsi.backuprbme.d70ea1

- Una vez que "veo" qué discos tiene, pues me conecto con ellos. En este ejemplo verás que hago login en un par de ellos, aunque el que te interesa es el que tiene "backuprbme" en su IQN

marte ~ # iscsiadm -m node -T iqn.2004-04.com.qnap:ts-569pro:iscsi.vmgentoo.d70ea1 -p 192.168.1.2 --login
marte ~ # iscsiadm -m node -T iqn.2004-04.com.qnap:ts-569pro:iscsi.backuprbme.d70ea1 -p 192.168.1.2 --login

- Tras hacer login en un target pasa a añadirse a la base de datos persistente de open-iscsi, que reside en /etc/iscsi/nodes y /etc/iscsi/send\_targets. Puedes ver qué tienes en la base de datos con los comandos siguientes:
    
- Comprobar la base de datos
    

marte ~ # iscsiadm -m discoverydb
192.168.1.2:3260 via sendtargets
marte ~ # iscsiadm -m discoverydb -t sendtargets -p 192.168.1.2:3260
# BEGIN RECORD 2.0-872
discovery.startup = manual
discovery.type = sendtargets
discovery.sendtargets.address = 192.168.1.2
discovery.sendtargets.port = 3260
discovery.sendtargets.auth.authmethod = None
discovery.sendtargets.auth.username = discovery.sendtargets.auth.password = discovery.sendtargets.auth.username\_in = discovery.sendtargets.auth.password\_in = discovery.sendtargets.timeo.login\_timeout = 15
discovery.sendtargets.use\_discoveryd = No
discovery.sendtargets.discoveryd\_poll\_inval = 30
discovery.sendtargets.reopen\_max = 5
discovery.sendtargets.timeo.auth\_timeout = 45
discovery.sendtargets.timeo.active\_timeout = 30
discovery.sendtargets.iscsi.MaxRecvDataSegmentLength = 32768
# END RECORD

marte ~ # iscsiadm -m node
192.168.1.2:3260,1 iqn.2004-04.com.qnap:ts-569pro:iscsi.backuprbme.d70ea1
192.168.1.2:3260,1 iqn.2004-04.com.qnap:ts-569pro:iscsi.vmgentoo.d70ea1

marte ~ # iscsiadm -m node -T iqn.2004-04.com.qnap:ts-569pro:iscsi.backuprbme.d70ea1
# BEGIN RECORD 2.0-872
node.name = iqn.2004-04.com.qnap:ts-569pro:iscsi.backuprbme.d70ea1
node.tpgt = 1
node.startup = manual
iface.hwaddress = iface.ipaddress = iface.iscsi\_ifacename = default
iface.net\_ifacename = iface.transport\_name = tcp
iface.initiatorname = node.discovery\_address = 192.168.1.2
node.discovery\_port = 3260
node.discovery\_type = send\_targets
node.session.initial\_cmdsn = 0
node.session.initial\_login\_retry\_max = 8
node.session.xmit\_thread\_priority = -20
node.session.cmds\_max = 128
node.session.queue\_depth = 32
node.session.auth.authmethod = None
node.session.auth.username = node.session.auth.password = node.session.auth.username\_in = node.session.auth.password\_in = node.session.timeo.replacement\_timeout = 120
node.session.err\_timeo.abort\_timeout = 15
node.session.err\_timeo.lu\_reset\_timeout = 30
node.session.err\_timeo.tgt\_reset\_timeout = 30
node.session.err\_timeo.host\_reset\_timeout = 60
node.session.iscsi.FastAbort = Yes
node.session.iscsi.InitialR2T = No
node.session.iscsi.ImmediateData = Yes
node.session.iscsi.FirstBurstLength = 262144
node.session.iscsi.MaxBurstLength = 16776192
node.session.iscsi.DefaultTime2Retain = 0
node.session.iscsi.DefaultTime2Wait = 2
node.session.iscsi.MaxConnections = 1
node.session.iscsi.MaxOutstandingR2T = 1
node.session.iscsi.ERL = 0
node.conn\[0\].address = 192.168.1.2
node.conn\[0\].port = 3260
node.conn\[0\].startup = manual
node.conn\[0\].tcp.window\_size = 524288
node.conn\[0\].tcp.type\_of\_service = 0
node.conn\[0\].timeo.logout\_timeout = 15
node.conn\[0\].timeo.login\_timeout = 15
node.conn\[0\].timeo.auth\_timeout = 45
node.conn\[0\].timeo.noop\_out\_interval = 5
node.conn\[0\].timeo.noop\_out\_timeout = 5
node.conn\[0\].iscsi.MaxXmitDataSegmentLength = 0
node.conn\[0\].iscsi.MaxRecvDataSegmentLength = 262144
node.conn\[0\].iscsi.HeaderDigest = None
node.conn\[0\].iscsi.DataDigest = None
node.conn\[0\].iscsi.IFMarker = No
node.conn\[0\].iscsi.OFMarker = No
# END RECORD 

#### Daemon y persistencia

- Configuro el sistema para que arranque open-iscsi durante el boot, haga login a los targets y además configure los discos iSCSI con nombres persistentes en /dev/iscsi/disk\*

\[Unit\]
Description=Open-iSCSI
Documentation=man:iscsid(8) man:iscsiuio(8) man:iscsiadm(8)
After=network.target NetworkManager-wait-online.service iscsiuio.service tgtd.service targetcli.service

\[Service\]
Type=forking
PIDFile=/var/run/iscsid.pid
ExecStart=/usr/sbin/iscsid
ExecStop=/sbin/iscsiadm -k 0 2

\[Install\]
WantedBy=multi-user.target

\[Unit\]
Description=Script post iSCSI
Wants=iscsid.service
After=iscsid.service

\[Service\]
Type=oneshot
ExecStart=/bin/bash /root/iscsi/iscsi\_start.sh
RemainAfterExit=yes

\[Install\]
WantedBy=multi-user.target

#!/bin/bash
#
iSCSI\_SERVER="192.168.1.2"
TARGETS="iqn.2004-04.com.qnap:ts-569pro:iscsi.vmgentoo.d70ea1 \\
         iqn.2004-04.com.qnap:ts-569pro:iscsi.backuprbme.d70ea1"

for TARGET in ${TARGETS}; do

    found=\`iscsiadm -m session | grep -i ${TARGET}\`
    if \[ "${found}" = "" \]; then
        iscsiadm -m node -T ${TARGET} -p ${iSCSI\_SERVER} --login
    fi
done

- Habilito los servicios

marte ~ # systemctl enable iscsid
marte ~ # systemctl enable post-iscsid

- Rearranco el equipo, dejo a continuación algunos comandos útiles para observar si todo ha ido bien. Deberías "ver" los discos conectados.

  
marte ~ # iscsiadm -m session
tcp: \[1\] 192.168.1.2:3260,1 iqn.2004-04.com.qnap:ts-569pro:iscsi.vmgentoo.d70ea1
tcp: \[2\] 192.168.1.2:3260,1 iqn.2004-04.com.qnap:ts-569pro:iscsi.backuprbme.d70ea1

marte ~ # ls -al /dev/iscsi/
total 0
drwxr-xr-x  2 root root  160 jun 21 13:19 .
drwxr-xr-x 17 root root 3620 jun 21 13:19 ..
lrwxrwxrwx  1 root root    6 jun 21 13:19 diska -> ../sdb
lrwxrwxrwx  1 root root    7 jun 21 13:19 diska1 -> ../sdb1
lrwxrwxrwx  1 root root    7 jun 21 13:19 diska2 -> ../sdb2
lrwxrwxrwx  1 root root    7 jun 21 13:19 diska3 -> ../sdb3
lrwxrwxrwx  1 root root    7 jun 21 13:19 diska4 -> ../sdb4
lrwxrwxrwx  1 root root    6 jun 21 13:19 diskb -> ../sdc

 

#### Configuro el disco, particiones, formato, etc.

A partir de aquí ya tengo mi disco iSCSI como /dev/iscsi/diskb y dicho nombre es persistente. El resto del proceso es igual que si fuese un disco físico o USB, de todas formas explico todo el proceso de configuración.

- Creo las particiones y el file system

\[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background\_color="#ffffff" border\_width="1" border\_color="#dddddd" \]

**NOTA**: Voy a usar gparted que no utiliza el link simbólico que acabo de mostrar anterioremente, así que asegúrate que estás eligiendo el disco adecuado. En mi caso es el /dev/sdc

\[/dropshadowbox\]

marte ~ # gparted

[![gparted-iscsi1](https://www.luispa.com/wp-content/uploads/2015/06/gparted-iscsi1.png)](https://www.luispa.com/wp-content/uploads/2015/06/gparted-iscsi1.png)

[![gparted-iscsi2](https://www.luispa.com/wp-content/uploads/2015/06/gparted-iscsi2.png)](https://www.luispa.com/wp-content/uploads/2015/06/gparted-iscsi2.png)

[![gparted-iscsi3](https://www.luispa.com/wp-content/uploads/2015/06/gparted-iscsi3.png)](https://www.luispa.com/wp-content/uploads/2015/06/gparted-iscsi3.png)

[![gparted-iscsi4](https://www.luispa.com/wp-content/uploads/2015/06/gparted-iscsi4.png)](https://www.luispa.com/wp-content/uploads/2015/06/gparted-iscsi4.png)

- Compruebo que todo es correcto, deberíamos ver que tenemos un disco con una partición 83 (linux) y aunque no se ve, el file system es de tipo EXT4.

marte ~ # fdisk -l /dev/iscsi/diskb

Disco /dev/iscsi/diskb: 250 GiB, 268435456000 bytes, 524288000 sectores
Unidades: sectores de 1 \* 512 = 512 bytes
Tamaño de sector (lógico/físico): 512 bytes / 512 bytes
Tamaño de E/S (mínimo/óptimo): 512 bytes / 33553920 bytes
Tipo de etiqueta de disco: dos
Identificador del disco: 0x1c19876e

Device            Boot Start       End   Sectors  Size Id Type
/dev/iscsi/diskb1       2048 524287999 524285952  250G 83 Linux

Tal como dije al principio, el directorio destino donde montaré este file system es /mnt/Backup. Este sistema utiliza systemd, así que preparo un par de ficheros para que se automonte el directorio.

\[Unit\]
Description=Automount /mnt/Backup

\[Automount\]
Where=/mnt/Backup

\[Install\]
WantedBy=multi-user.target

\[Unit\]
Description=Backup
Wants=iscsid.service
After=iscsid.service

\[Mount\]
What=/dev/iscsi/diskb1
Where=/mnt/Backup
Type=ext4
StandardOutput=syslog
StandardError=syslog

\[Install\]
WantedBy=multi-user.target

- Habilito su montaje durante el arranque del equipo.

marte system # systemctl enable mnt-Backup.automount
marte system # systemctl enable mnt-Backup.mount

- Monto el file system y creo un fichero de control para poder usarlo en mi script.

marte ~ # mount /mnt/Backup
marte ~ # touch /mnt/Backup/.Disco\_Backup\_iSCSI.txt

- Veamos la configuración que utilizo para este caso

Preparo el fichero de configuración de RBME. Nota: Debes modificar y adaptar este fichero de configuración a tu caso concreto, este es solo un ejemplo.

BACKUP\_PATH="/mnt/Backup"
MIN\_FREE\_BEFORE\_HOST\_BACKUP="30000"
MIN\_INODES\_BEFORE\_HOST\_BACKUP="100000"
MIN\_FREE\_AFTER\_HOST\_BACKUP="40000"
MIN\_INODES\_AFTER\_HOST\_BACKUP="300000"
MIN\_KEEP\_OLD\_BACKUPS="30"
VERBOSE=${VERBOSE=}
STATISTICS="yes"
MAILTO="tusuario@tudominio.com"
MAILFROM="root@tuhost"
MAILSTYLE="all"
LOGFILE=$(date +"/var/log/$ME.log.%d")
RSYNC\_RSH="ssh -c blowfish-cbc”

Preparo un script para que se ejecute diariamente desde el cron. Nota que este es solo un ejemplo, debes adaptar el script a tu configuración de directorio(s) y nombres de servidor.

#!/bin/bash
#
iSCSI\_SERVER="192.168.1.2"
TARGET="iqn.2004-04.com.qnap:ts-569pro:iscsi.backuprbme.d70ea1"

# Si la VM está arrancada la paro.
#
aplicacionix\_on=\`virsh dominfo aplicacionix | grep -i Estado | grep -i ejecutando\`
if \[ "${aplicacionix\_on}" != "" \]; then
    echo "Parro 'aplicacionix'"
    vm\_was\_on="yes"
    virsh shutdown aplicacionix
fi

# Confirmo que tengo el directorio /mnt/Backup activo
#
found=\`iscsiadm -m session | grep -i ${TARGET}\`
if \[ "${found}" = "" \]; then
    echo "Login con el servidor iSCSI"
    iscsiadm -m node -T ${TARGET} -p ${iSCSI\_SERVER} --login
fi

wasMounted="no"
if \[ ! -f "/mnt/Backup/.Disco\_Backup\_iSCSI.txt" \];
then
    echo "Monto /mnt/Backup"
    mount /mnt/Backup
else
    wasMounted="yes"
fi

# Ejecuto el backup
#
if \[ -f "/mnt/Backup/.Disco\_Backup\_iSCSI.txt" \];
then
    echo "Backup desde /Apps a /mnt/Backup"
    rbme marte:/Apps
    if \[ "${wasMounted}" = "no" \]; then
        umount /mnt/Backup
    fi
fi

# Si la VM estaba arrancada la vuelvo a activar
#
if \[ "${vm\_was\_on}" = "yes" \]; then
    echo "Arranco 'aplicacionix'"
    virsh start aplicacionix
fi

 

## Conclusión

El resultado es satisfactorio, todos los días se realiza una copia incremental (usando hardlinks) de los datos fuentes, por lo que puedo recuperar una copia COMPLETA del estado en el que se encontraban en cualquier día del pasado. El script se va a encargar de ir borrando las copias antiguas una vez se llene el disco.
