---
title: "RBME: Backup incremental en Linux"
date: "2014-11-23"
categories: gentoo
tags: linux
excerpt_separator: <!--more-->
---

En este artículo explico el metodo que uso para hacer backup de mis datos persistentes de mi servidor Linux a un disco externo. La técnica está basada en Rsync y backups [incrementales usando Hard Links](http://earlruby.org/2013/05/creating-differential-backups-with-hard-links-and-rsync/) mediante el script ![RBME](/assets/img/original/rbme){: width="730px" padding:10px } que facilita todo el proceso.

![backup](/assets/img/original/backup-1024x830.png){: width="730px" padding:10px }

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
today="$(date "+%Y-%m-%d_%H-%M-%S")"
:

Las configuraciones las detallo en cada opción de disco.

 

## Backup a disco USB

La primera opción, usar un disco externo USB para hacer backup. También valdría que fuese 2.0 pero hoy en día no merece la pena.

![usb](/assets/img/original/usb-300x162.png){: width="730px" padding:10px }

Utilizo un disco que ya tenía para otros menesteres y creo una partición de tipo EXT4 con el resto del espacio usando gparted.

![gparted](/assets/img/original/gparted.png){: width="730px" padding:10px }

El proceso es muy sencillo, conectamos el USB, entramos como root y ejecutamos gparted. Seleccionamos el espacio libre y creamos una partición de tipo ext4.

Añado la nueva partición al /etc/fstab para que se monte en /mnt/Backup.

/dev/sdb2  /mnt/Backup ext4  noatime  0 0

- Monto el file system y creo un fichero de control para poder usarlo en mi script.

marte ~ # mount /mnt/Backup
marte ~ # touch /mnt/Backup/.Disco_Backup_USB.txt

- Veamos la configuración que utilizo para este caso

Preparo el fichero de configuración de RBME /etc/rbme.conf Nota: Debes modificar y adaptar este fichero de configuración a tu caso concreto, este es solo un ejemplo.

BACKUP_PATH="/mnt/Backup"
MIN_FREE_BEFORE_HOST_BACKUP="30000"
MIN_INODES_BEFORE_HOST_BACKUP="100000"
MIN_FREE_AFTER_HOST_BACKUP="40000"
MIN_INODES_AFTER_HOST_BACKUP="300000"
MIN_KEEP_OLD_BACKUPS="30"
VERBOSE=${VERBOSE=}
STATISTICS="yes"
MAILTO="tusuario@tudominio.com"
MAILFROM="root@tuhost"
MAILSTYLE="all"
LOGFILE=$(date +"/var/log/$ME.log.%d")
RSYNC_RSH="ssh -c blowfish-cbc”

Preparo un script /etc/cron.daily/rbme_daily.sh para que se ejecute diariamente desde el cron. Nota que este es solo un ejemplo, debes adaptar el script a tu configuración de directorio(s) y nombres de servidor.

/rbme_daily.sh"]
#!/bin/bash
#
vm_NAME="aplicacionix-file"
iSCSI_SERVER="192.168.1.2"
TARGET="iqn.2004-04.com.qnap:ts-569pro:iscsi.backuprbme.d70ea1"

# mandar mensaje por correo
#
manda_mensaje() {
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
vm_is_on="0"
vm_was_on="0"
num="0"
while true; do

    # Check if VM is up and running, if so shut it down
    vm_list=\`virsh list --all | grep -i aplicacionix-file\`
    aplicacionix_name=\`echo ${vm_list} | gawk '{print $2}'\`
    aplicacionix_state=\`echo ${vm_list} | gawk '{print $3}'\`
    echo ${aplicacionix_name}
    echo ${aplicacionix_state}
    if [ "${aplicacionix_state}" == "ejecutando" ]; then
        vm_was_on="1"
        vm_is_on="1"
        if [ "${num}" == "3" ]; then
            break
        fi
        num=$((num+1))
        echo "La VM '${aplicacionix_name}' esta ejecutandose, ejecuto su apagado (intento ${num})"
        virsh shutdown ${aplicacionix_name}
        sleep 10
    else
        if [ "${aplicacionix_state}" == "apagado" ]; then
            vm_is_on="0"
            break
        fi
    fi
done

# Si no consigo pararla me piro
#
if [ "${vm_is_on}" = "1" ]; then
    manda_mensaje "He interrumpido el backup RBME porque no se ha podido parar la maquina virtual: ${aplicacionix_name}"
    exit
fi

# Confirmo que tengo el directorio /mnt/Backup activo
#
found=\`iscsiadm -m session | grep -i ${TARGET}\`
if [ "${found}" = "" ]; then
    echo "Login con el servidor iSCSI"
    iscsiadm -m node -T ${TARGET} -p ${iSCSI_SERVER} --login
fi

wasMounted="no"
if [ ! -f "/mnt/Backup/.Disco_Backup_iSCSI.txt" ];
then
    echo "Monto /mnt/Backup"
    mount /mnt/Backup
else
    wasMounted="yes"
fi

# Ejecuto el backup
#
if [ -f "/mnt/Backup/.Disco_Backup_iSCSI.txt" ];
then
    echo "Backup desde /Apps a /mnt/Backup"
    rbme marte:/Apps
    #
    # Si no estaba originalmente montado pues lo vuelvo a desmontar
    if [ "${wasMounted}" = "no" ]; then
        umount /mnt/Backup
    fi
fi

# Si la VM estaba arrancada la vuelvo a activar
#
if [ "${vm_was_on}" = "1" ]; then
    echo "Arranco '${aplicacionix_name}'"
    virsh start ${aplicacionix_name}

    # La VM que estoy parando tiene mi servidor de correo asi que he creado 
    # un script para automandarme un mensaje dentro de un rato con el log
    # que genera el programa rbme
    sleep 90
    /root/priv/bin/manda_mail.sh
fi

La VM que estoy parando tiene mi servidor de correo asi que he modificado el ejecutable rbme (añado la lína: cat "$LOGFILE" > /tmp/mandar.txt) y he creado un script para automandarme un mensaje al terminar el script anterior:

- /root/priv/bin/manda_mail.sh"

<

pre> #!/bin/bash # if test /tmp/mandar.txt ; then { echo "From: Marte" echo "To: Luis Palacios" echo "Subject: Backup RBME" echo "Content-Type: text/plain; charset=UTF-8" echo "" cat /tmp/mandar.txt } | /usr/sbin/sendmail -f "root@marte" usuario@dominio.com fi

<

pre>

 

## Backup a disco iSCSI

Otra opción muy interesante es usar un disco remoto en una NAS a través de iSCSI. En mi caso tengo una NAS de QNAP, un ![Hypervisor KVM](https://www.luispa.com/?p=3221) y mis máquinas virtuales ([un ejemplo](/assets/img/original/?p=3462)){: width="730px" padding:10px }. Si mezclamos los ingredientes tenemos un caso de uso claro: entregar un espacio "físico" vía iSCSI desde la NAS al hypervisor, para que haga backups con RBME de los datos persistentes de las máquinas virtuales.

### Acciones en el QNAP

- Creo un espacio libre de 250GB en mi QNAP (NAS)

![iSCSI-RBME-1](/assets/img/original/iSCSI-RBME-1-1024x595.png){: width="730px" padding:10px }

![iSCSI-RBME-2](/assets/img/original/iSCSI-RBME-2-1024x602.png){: width="730px" padding:10px }

![iSCSI-RBME-3](/assets/img/original/iSCSI-RBME-3-1024x602.png){: width="730px" padding:10px }

![iSCSI-RBME-4](/assets/img/original/iSCSI-RBME-4-1024x601.png){: width="730px" padding:10px }

![iSCSI-RBME-5](/assets/img/original/iSCSI-RBME-5-1024x591.png){: width="730px" padding:10px }

- Me apunto el target: iqn.2004-04.com.qnap:ts-569pro:iscsi.backuprbme.d70ea1

 

### Acciones en el Linux donde ejecuto RBME

Como decía antes, estoy entregando un espacio "físico" vía iSCSI desde la NAS al hypervisor, para que haga backups con RBME de los datos persistentes de las máquinas virtuales. Esto significa que el Linux (hypervisor) tiene acceso a los datos persistentes que modifican sus VM's y tiene la capacidad de apagar las VM's, hacer backup y volver a arrancarlas, así que me ha parecido el sitio más adecuado.

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

![este otro apunte](/assets/img/original/?p=3462)){: width="730px" padding:10px }.

[/dropshadowbox]

- Para poder configurar discos iSCSI hay que hacer un discovery a ver que me ofrece el NAS

marte ~ # iscsiadm -m discovery --portal=192.168.1.2:3260 -t sendtargets
192.168.1.2:3260,1 iqn.2004-04.com.qnap:ts-569pro:iscsi.vmgentoo.d70ea1
192.168.1.2:3260,1 iqn.2004-04.com.qnap:ts-569pro:iscsi.backuprbme.d70ea1

- Una vez que "veo" qué discos tiene, pues me conecto con ellos. En este ejemplo verás que hago login en un par de ellos, aunque el que te interesa es el que tiene "backuprbme" en su IQN

marte ~ # iscsiadm -m node -T iqn.2004-04.com.qnap:ts-569pro:iscsi.vmgentoo.d70ea1 -p 192.168.1.2 --login
marte ~ # iscsiadm -m node -T iqn.2004-04.com.qnap:ts-569pro:iscsi.backuprbme.d70ea1 -p 192.168.1.2 --login

- Tras hacer login en un target pasa a añadirse a la base de datos persistente de open-iscsi, que reside en /etc/iscsi/nodes y /etc/iscsi/send_targets. Puedes ver qué tienes en la base de datos con los comandos siguientes:
    
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
discovery.sendtargets.auth.username = discovery.sendtargets.auth.password = discovery.sendtargets.auth.username_in = discovery.sendtargets.auth.password_in = discovery.sendtargets.timeo.login_timeout = 15
discovery.sendtargets.use_discoveryd = No
discovery.sendtargets.discoveryd_poll_inval = 30
discovery.sendtargets.reopen_max = 5
discovery.sendtargets.timeo.auth_timeout = 45
discovery.sendtargets.timeo.active_timeout = 30
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
iface.hwaddress = iface.ipaddress = iface.iscsi_ifacename = default
iface.net_ifacename = iface.transport_name = tcp
iface.initiatorname = node.discovery_address = 192.168.1.2
node.discovery_port = 3260
node.discovery_type = send_targets
node.session.initial_cmdsn = 0
node.session.initial_login_retry_max = 8
node.session.xmit_thread_priority = -20
node.session.cmds_max = 128
node.session.queue_depth = 32
node.session.auth.authmethod = None
node.session.auth.username = node.session.auth.password = node.session.auth.username_in = node.session.auth.password_in = node.session.timeo.replacement_timeout = 120
node.session.err_timeo.abort_timeout = 15
node.session.err_timeo.lu_reset_timeout = 30
node.session.err_timeo.tgt_reset_timeout = 30
node.session.err_timeo.host_reset_timeout = 60
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
node.conn[0].address = 192.168.1.2
node.conn[0].port = 3260
node.conn[0].startup = manual
node.conn[0].tcp.window_size = 524288
node.conn[0].tcp.type_of_service = 0
node.conn[0].timeo.logout_timeout = 15
node.conn[0].timeo.login_timeout = 15
node.conn[0].timeo.auth_timeout = 45
node.conn[0].timeo.noop_out_interval = 5
node.conn[0].timeo.noop_out_timeout = 5
node.conn[0].iscsi.MaxXmitDataSegmentLength = 0
node.conn[0].iscsi.MaxRecvDataSegmentLength = 262144
node.conn[0].iscsi.HeaderDigest = None
node.conn[0].iscsi.DataDigest = None
node.conn[0].iscsi.IFMarker = No
node.conn[0].iscsi.OFMarker = No
# END RECORD 

#### Daemon y persistencia

- Configuro el sistema para que arranque open-iscsi durante el boot, haga login a los targets y además configure los discos iSCSI con nombres persistentes en /dev/iscsi/disk*

[Unit]
Description=Open-iSCSI
Documentation=man:iscsid(8) man:iscsiuio(8) man:iscsiadm(8)
After=network.target NetworkManager-wait-online.service iscsiuio.service tgtd.service targetcli.service

[Service]
Type=forking
PIDFile=/var/run/iscsid.pid
ExecStart=/usr/sbin/iscsid
ExecStop=/sbin/iscsiadm -k 0 2

[Install]
WantedBy=multi-user.target

[Unit]
Description=Script post iSCSI
Wants=iscsid.service
After=iscsid.service

[Service]
Type=oneshot
ExecStart=/bin/bash /root/iscsi/iscsi_start.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target

#!/bin/bash
#
iSCSI_SERVER="192.168.1.2"
TARGETS="iqn.2004-04.com.qnap:ts-569pro:iscsi.vmgentoo.d70ea1 \
         iqn.2004-04.com.qnap:ts-569pro:iscsi.backuprbme.d70ea1"

for TARGET in ${TARGETS}; do

    found=\`iscsiadm -m session | grep -i ${TARGET}\`
    if [ "${found}" = "" ]; then
        iscsiadm -m node -T ${TARGET} -p ${iSCSI_SERVER} --login
    fi
done

- Habilito los servicios

marte ~ # systemctl enable iscsid
marte ~ # systemctl enable post-iscsid

- Rearranco el equipo, dejo a continuación algunos comandos útiles para observar si todo ha ido bien. Deberías "ver" los discos conectados.

  
marte ~ # iscsiadm -m session
tcp: [1] 192.168.1.2:3260,1 iqn.2004-04.com.qnap:ts-569pro:iscsi.vmgentoo.d70ea1
tcp: [2] 192.168.1.2:3260,1 iqn.2004-04.com.qnap:ts-569pro:iscsi.backuprbme.d70ea1

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

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**NOTA**: Voy a usar gparted que no utiliza el link simbólico que acabo de mostrar anterioremente, así que asegúrate que estás eligiendo el disco adecuado. En mi caso es el /dev/sdc

[/dropshadowbox]

marte ~ # gparted

![gparted-iscsi1](/assets/img/original/gparted-iscsi1.png){: width="730px" padding:10px }

![gparted-iscsi2](/assets/img/original/gparted-iscsi2.png){: width="730px" padding:10px }

![gparted-iscsi3](/assets/img/original/gparted-iscsi3.png){: width="730px" padding:10px }

![gparted-iscsi4](/assets/img/original/gparted-iscsi4.png){: width="730px" padding:10px }

- Compruebo que todo es correcto, deberíamos ver que tenemos un disco con una partición 83 (linux) y aunque no se ve, el file system es de tipo EXT4.

marte ~ # fdisk -l /dev/iscsi/diskb

Disco /dev/iscsi/diskb: 250 GiB, 268435456000 bytes, 524288000 sectores
Unidades: sectores de 1 * 512 = 512 bytes
Tamaño de sector (lógico/físico): 512 bytes / 512 bytes
Tamaño de E/S (mínimo/óptimo): 512 bytes / 33553920 bytes
Tipo de etiqueta de disco: dos
Identificador del disco: 0x1c19876e

Device            Boot Start       End   Sectors  Size Id Type
/dev/iscsi/diskb1       2048 524287999 524285952  250G 83 Linux

Tal como dije al principio, el directorio destino donde montaré este file system es /mnt/Backup. Este sistema utiliza systemd, así que preparo un par de ficheros para que se automonte el directorio.

[Unit]
Description=Automount /mnt/Backup

[Automount]
Where=/mnt/Backup

[Install]
WantedBy=multi-user.target

[Unit]
Description=Backup
Wants=iscsid.service
After=iscsid.service

[Mount]
What=/dev/iscsi/diskb1
Where=/mnt/Backup
Type=ext4
StandardOutput=syslog
StandardError=syslog

[Install]
WantedBy=multi-user.target

- Habilito su montaje durante el arranque del equipo.

marte system # systemctl enable mnt-Backup.automount
marte system # systemctl enable mnt-Backup.mount

- Monto el file system y creo un fichero de control para poder usarlo en mi script.

marte ~ # mount /mnt/Backup
marte ~ # touch /mnt/Backup/.Disco_Backup_iSCSI.txt

- Veamos la configuración que utilizo para este caso

Preparo el fichero de configuración de RBME. Nota: Debes modificar y adaptar este fichero de configuración a tu caso concreto, este es solo un ejemplo.

BACKUP_PATH="/mnt/Backup"
MIN_FREE_BEFORE_HOST_BACKUP="30000"
MIN_INODES_BEFORE_HOST_BACKUP="100000"
MIN_FREE_AFTER_HOST_BACKUP="40000"
MIN_INODES_AFTER_HOST_BACKUP="300000"
MIN_KEEP_OLD_BACKUPS="30"
VERBOSE=${VERBOSE=}
STATISTICS="yes"
MAILTO="tusuario@tudominio.com"
MAILFROM="root@tuhost"
MAILSTYLE="all"
LOGFILE=$(date +"/var/log/$ME.log.%d")
RSYNC_RSH="ssh -c blowfish-cbc”

Preparo un script para que se ejecute diariamente desde el cron. Nota que este es solo un ejemplo, debes adaptar el script a tu configuración de directorio(s) y nombres de servidor.

#!/bin/bash
#
iSCSI_SERVER="192.168.1.2"
TARGET="iqn.2004-04.com.qnap:ts-569pro:iscsi.backuprbme.d70ea1"

# Si la VM está arrancada la paro.
#
aplicacionix_on=\`virsh dominfo aplicacionix | grep -i Estado | grep -i ejecutando\`
if [ "${aplicacionix_on}" != "" ]; then
    echo "Parro 'aplicacionix'"
    vm_was_on="yes"
    virsh shutdown aplicacionix
fi

# Confirmo que tengo el directorio /mnt/Backup activo
#
found=\`iscsiadm -m session | grep -i ${TARGET}\`
if [ "${found}" = "" ]; then
    echo "Login con el servidor iSCSI"
    iscsiadm -m node -T ${TARGET} -p ${iSCSI_SERVER} --login
fi

wasMounted="no"
if [ ! -f "/mnt/Backup/.Disco_Backup_iSCSI.txt" ];
then
    echo "Monto /mnt/Backup"
    mount /mnt/Backup
else
    wasMounted="yes"
fi

# Ejecuto el backup
#
if [ -f "/mnt/Backup/.Disco_Backup_iSCSI.txt" ];
then
    echo "Backup desde /Apps a /mnt/Backup"
    rbme marte:/Apps
    if [ "${wasMounted}" = "no" ]; then
        umount /mnt/Backup
    fi
fi

# Si la VM estaba arrancada la vuelvo a activar
#
if [ "${vm_was_on}" = "yes" ]; then
    echo "Arranco 'aplicacionix'"
    virsh start aplicacionix
fi

 

## Conclusión

El resultado es satisfactorio, todos los días se realiza una copia incremental (usando hardlinks) de los datos fuentes, por lo que puedo recuperar una copia COMPLETA del estado en el que se encontraban en cualquier día del pasado. El script se va a encargar de ir borrando las copias antiguas una vez se llene el disco.
