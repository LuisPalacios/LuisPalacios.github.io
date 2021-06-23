---
title: "Systemd de usuario"
date: "2021-05-30"
categories: linux
tags: systemd service usuario
excerpt_separator: <!--more-->
---

![logo systemd](/assets/img/posts/logo-systemd.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 

El gestor [systemd](https://systemd.io/) permite configurar servicios desde un usuario normal del sistema. Estos ***servicios de usuario de systemd*** son una funcionalidad poco conocida pero muy útil. Consiste en poder crear y usar ficheros `.service` desde un directorio local del usuario y que se ejecuten con sus privilegios. 

<br clear="left"/>
<!--more-->

[systemd](https://systemd.io/) es un gestor de sistemas y servicios para Linux que se ejecuta como PID 1 y arranca todo el sistema. Permite paralelización, usa sockets y D-Bus para iniciar los servicios, inicia demonios, monitoriza y gestiona procesos, puntos de montaje. Desplazó a `sysvinit` como estándar de facto hace ya tiempo.

Tiene una funcionalidad muy interesante llamada "user lingering" que consiste en ejecutar instancias de *systemd* como usuario normal del sistema. Eso nos va a permitir lanzar procesos de usuario durante el arranque del sistema.

<br/> 

### Configuración

Veamos un ejemplo. Tengo una [maquina virtual para desarrollo de software preparada con Vagrant](https://github.com/LuisPalacios/devbox) que quiero arrancar durante el boot de un equipo Linux llamado `jupiter` *como usuario* normal `luis`.

* Conecto como `luis` 

```console
luis @ idefix ➜  ~  ssh -Y -a luis@jupiter.parchis.org
luis@jupiter:~$ 
```

* Le doy permiso a `luis` (desde `root`) para habilitar esta función de *lingering*

```console
luis@jupiter:~$ sudo loginctl enable-linger luis
luis@jupiter:~$
```

* Me preparo mi fichero: `~/.config/systemd/user/devbox.service`:

```conf
[Unit]
AssertPathExists=/home/luis/devbox

[Service]
WorkingDirectory=/home/luis/devbox
ExecStart=/usr/bin/vagrant up
Restart=always
PrivateTmp=true
NoNewPrivileges=true

[Install]
WantedBy=default.target
```

* Habilito, arranco, consulto el servicio `devbox.service`

```console
luis@jupiter:~$ systemctl --user enable devbox.service
Created symlink /home/luis/.config/systemd/user/default.target.wants/devbox.service → /home/luis/.config/systemd/user/devbox.service.
```

```console
luis@jupiter:~$ systemctl --user start devbox
luis@jupiter:~$ systemctl --user status devbox
● devbox.service
     Loaded: loaded (/home/luis/.config/systemd/user/devbox.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2021-05-30 13:52:41 CEST; 37s ago
   Main PID: 4541 (vagrant)
      Tasks: 4 (limit: 18983)
     Memory: 71.2M
        CPU: 2.990s
     CGroup: /user.slice/user-1000.slice/user@1000.service/app.slice/devbox.service
             └─4541 /usr/bin/ruby /usr/bin/vagrant up

:
```

* A partir de ahora, cada vez que se rearranque el gestor `systemd` ejecutará el comando `vagrant up` (como usuario `luis`) durante el boot. 

<br/>

---

<br/>

| Nota: En mi caso reicibí el error `Failed to connect to bus: $DBUS_SESSION_BUS_ADDRESS and $XDG_RUNTIME_DIR not defined`. Estaba conectando vía `ssh`y el servidor tenía la opción `UsePAM no`. La cambié a `UsePAM yes`, rearranqué el servidor `sshd` y volví a conectar |

