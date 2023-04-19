---
title: "Socketed SSH"
date: "2023-04-14"
categories: administración
tags: ssh sshd systemd socket socketed linux
excerpt_separator: <!--more-->
---


![logo linux router](/assets/img/posts/logo-socketed-ssh.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

[Systemd](https://systemd.io) es un sistema utilizado en linux para administrar el arranque y los procesos del sistema. Una parte importante son sus **"unidades"** (`units`), que son archivos de configuración que describen los procesos y servicios que `systemd` debe administrar.

Una de estas unidades es la `systemd.socket`, que permite activar un servicio cuando se establece una conexión a través de un socket con el equipo. Un socket es una forma de comunicación entre procesos en una red (o en el mismo sistema). Al crear una unidad de este tipo le estamos pidiendo que escuche en un socket determinado y si recibe una conexión que inicie un servicio específico.

<br clear="left"/>
<!--more-->

### Introducción

Por ejemplo, si creamos `apache.socket`, podemos decirle a systemd que inicie el servicio de Apache solo cuando se reciba una conexión a través del puerto 80, que es el puerto estándar para las solicitudes web. Esto significa que Apache solo se ejecutará cuando sea necesario, lo que puede ahorrar recursos del sistema.

Podríamos hacer lo mismo creando `ssh.socket`, le pedimos a `systemd` que inicie el servicio de OpenSSH solo cuando reciba una petición de conexión a través del puerto 22. 

<br/>

#### SSHD por puerto no estándar

En este apunte vamos a ver algo ligeramente distinto. El desencadenante es que tanto Debian como Ubuntu han cambiado la forma de configurar OpenSSH y ahora utilizan `systemd socket activation`. 

**¿Cómo hacemos para cambiar el puerto por defecto por otro distinto (por ejemplo el `12345`)?.**

Ya no vale con cambiar el fichero `/etc/ssh/sshd_config`, porque ha dejado de usarse. Lo que tenemos que hacer es cambiar la configuración de la unidad `.socket`. 

* `/etc/systemd/system/sockets.target.wants/ssh.socket` 

```conf
[Unit]
Description=OpenBSD Secure Shell server socket
Before=ssh.service
Conflicts=ssh.service
ConditionPathExists=!/etc/ssh/sshd_not_to_be_run

[Socket]
ListenStream=22
Accept=yes

[Install]
WantedBy=sockets.target
```

Lo correcto es crear un fichero que la sobreescriba, no modificar la unidad directamente (**no sobreviviría a un `apt update`**). Creo el fichero siguiente: 

* `/etc/systemd/system/ssh.socket.d/ssh-override.conf`

```zsh
mkdir -p /etc/systemd/system/ssh.socket.d/
cat > /etc/systemd/system/ssh.socket.d/ssh-override.conf << EOF
[Socket]
ListenStream=
ListenStream=12345
EOF

systemctl daemon-reload
systemctl restart ssh.socket
```

La línea `ListenStream=` hace que deje de escuchar en el puerto `22` y la segunda `ListenStream=12345` es el puerto por el que va a escuchar a partir de ahora.

<br/>

#### Comprobar el cambio

Si rearrancas el equipo (sin ninguna conexión SSH) y pudieses conectar a su consola (en directo o vía Serial, por ejemplo con `virsh`) podrías ver lo siguiente: 

```zsh
root@debian:~# systemctl status ssh.socket
* ssh.socket - OpenBSD Secure Shell server socket
     Loaded: loaded (/lib/systemd/system/ssh.socket; enabled; vendor preset: enabled)
    Drop-In: /etc/systemd/system/ssh.socket.d
             `-ssh-override.conf
     Active: active (listening) since Wed 2023-04-19 19:17:21 CEST; 16s ago
     Listen: [::]:12345 (Stream)
   Accepted: 0; Connected: 0;
     CGroup: /system.slice/ssh.socket

Apr 19 19:17:21 npm systemd[1]: Listening on OpenBSD Secure Shell server socket.

root@debian:~# netstat -tpuln| grep  '22\|12345'
tcp6       0      0 :::12345                 :::*                    LISTEN      1/init    

root@debian:~# ps -ef | grep -i "[s]shd"
root@debian:~# 
```

- El unit `ssh.socket` está activo y está escuchando en el puerto `12345`.
- Buscando procesos escuchando en `22` o `12345`  solo está systemd (init) en el  `12345`  
- No hay ningún daemon `sshd` no está arrancado


Si me conecto desde un cliente con `ssh` y repito los comandos: 

```zsh
$ ssh -p 12345 root@192.168.1.123
root@192.168.100.123 password:
Debian LXC
Last login: Wed Apr 19 22:17:29 2023
root@debian:~#

root@npmdebian:~# systemctl status ssh.socket
● ssh.socket - OpenBSD Secure Shell server socket
     Loaded: loaded (/lib/systemd/system/ssh.socket; enabled; vendor preset: enabled)
    Drop-In: /etc/systemd/system/ssh.socket.d
             └─ssh-override.conf
     Active: active (listening) since Wed 2023-04-19 22:17:21 CEST; 10min ago
   Triggers: ● ssh@0-192.168.1.123:1443-192.168.1.12:54596.service
     Listen: [::]:12345 (Stream)
   Accepted: 1; Connected: 1;
     CGroup: /system.slice/ssh.socket

root@debian:~# netstat -tpuln| grep  '22\|12345'
tcp6       0      0 :::12345                 :::*                    LISTEN      1/init    

root@debian:~# ps -ef | grep -i "[s]shd"
root         402       1  0 19:26 ?        00:00:00 sshd: root@pts/3
```

- El unit `ssh.socket` está activo, está escuchando en el puerto `12345` y ha tenido un disparador que ha provocado arrancar `sshd` 
- Buscando procesos escuchando en `22` o `12345`  seguimos viendo que systemd (init) es el único que escucha y solo en el  `12345`  
- Ahora si que hay un proceso `sshd` arrancado atendiendo al cliente que ha pedido la conexión.
