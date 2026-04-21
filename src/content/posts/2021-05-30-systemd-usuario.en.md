---
title: "User Systemd Services"
date: "2021-05-30"
categories: ["linux"]
tags: ["systemd","service","user"]
draft: false
cover:
  image: "/img/posts/logo-systemd.svg"
  hidden: true
---

<img src="/img/posts/logo-systemd.svg" alt="systemd logo" width="150px" height="150px" style="float:left; padding-right:25px"  />

The [systemd](https://systemd.io/) manager allows configuring services from a normal system user. These ***systemd user services*** are a little-known but very useful feature. It consists of being able to create and use `.service` files from a user's local directory that run with their privileges.

<br clear="left"/>
<!--more-->

[systemd](https://systemd.io/) is a system and service manager for Linux that runs as PID 1 and boots the entire system. It enables parallelization, uses sockets and D-Bus to start services, launches daemons, monitors and manages processes and mount points. It displaced `sysvinit` as the de facto standard some time ago.

It has a very interesting feature called "user lingering" which consists of running *systemd* instances as a normal system user. This will allow us to launch user processes during system boot.

<br/>

### Configuration

Let's look at an example. I have a [virtual machine for software development prepared with Vagrant](https://github.com/LuisPalacios/devbox) that I want to start during boot on a Linux machine called `jupiter` *as a normal user* `luis`.

- I connect as `luis`

```shell
luis @ idefix ➜  ~  ssh -Y -a luis@jupiter.tudominio.com
luis@jupiter:~$
```

- I grant permission to `luis` (from `root`) to enable this *lingering* feature

```shell
luis@jupiter:~$ sudo loginctl enable-linger luis
luis@jupiter:~$
```

- I prepare my file: `~/.config/systemd/user/devbox.service`:

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

- I enable, start, and check the `devbox.service`

```shell
luis@jupiter:~$ systemctl --user enable devbox.service
Created symlink /home/luis/.config/systemd/user/default.target.wants/devbox.service → /home/luis/.config/systemd/user/devbox.service.
```

```shell
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

- From now on, every time the system restarts, the `systemd` manager will execute the `vagrant up` command (as user `luis`) during boot.

<br/>

---

<br/>

| Note: In my case I received the error `Failed to connect to bus: $DBUS_SESSION_BUS_ADDRESS and $XDG_RUNTIME_DIR not defined`. I was connecting via `ssh` and the server had the option `UsePAM no`. I changed it to `UsePAM yes`, restarted the `sshd` server, and reconnected |
