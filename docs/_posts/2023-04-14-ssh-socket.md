---
title: "Socketed SSH"
date: "2023-04-14"
categories: administración
tags: ssh sshd systemd socket socketed linux
excerpt_separator: <!--more-->
---


![logo linux router](/assets/img/posts/logo-socketed-ssh.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

[Systemd](https://systemd.io) es un sistema utilizado en linux para administrar el arranque y los procesos del sistema. Sus **"unidades"** (`units`) son archivos de configuración que describen los procesos y servicios que `systemd` administra.

Una de estas unidades es la `systemd.socket`, que arranca el daemon correspondiente cuando se establece una conexión a través de un socket con el equipo. Un socket es una forma de comunicación entre procesos en red o en el sistema. Al crear una unidad de este tipo le estamos pidiendo que escuche en un socket determinado y si recibe una conexión que inicie un servicio específico.

<br clear="left"/>
<!--more-->

### Introducción

Por ejemplo, si creamos `apache.socket`, le pedimos a *systemd* que inicie el servidor Apache en cuanto se reciba la primera petición de conexión puerto `80` (estándar para solicitudes web). Apache solo se ejecutará cuando sea necesario, lo que puede ahorrar recursos del sistema. Podríamos hacer lo mismo creando `ssh.socket`, le pedimos a `systemd` que inicie el servicio de OpenSSH solo cuando reciba una petición de conexión a través del puerto 22. 

<br/>

#### SSHD por puerto no estándar

Debian como Ubuntu han cambiado la forma de configurar OpenSSH y ahora utilizan `systemd socket activation`. Si queremos cambiar el puerto estándar ya no se hace en el fichero `/etc/ssh/sshd_config`. De hecho, tampoco recomiendo modificando la unidad  `/etc/systemd/system/sockets.target.wants/ssh.socket` (**no sobreviviría a un `apt update`**). Lo correcto es crear el fichero siguiente: 

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

Si rearrancas el equipo (sin ninguna conexión SSH) y pudieses conectar a su consola (en directo o vía Serial, por ejemplo con `virsh`) podrás comprobarlo mejor:

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
