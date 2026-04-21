---
title: "Daily Reboot with Systemd"
date: "2023-07-23"
categories: ["infrastructure"]
tags: ["linux","reboot","systemd","daily","scheduled","restart"]
draft: false
cover:
  image: "/img/posts/logo-systemd-reboot.svg"
  hidden: true
---

<img src="/img/posts/logo-systemd-reboot.svg" alt="systemd reboot logo" width="150px" height="150px" style="float:left; padding-right:25px"  />

To perform a full reboot you can use the `systemctl reboot` command, but how can you schedule it at a specific time? In this post I explain how to do it using [systemd](https://systemd.io/), the boot manager and administration system for Linux distributions.

Among the ***systemd timer services*** there's a little-known feature that allows you to schedule an automatic reboot whenever you want.

<br clear="left"/>
<!--more-->

### Timer for Daily Reboot

I create a `reboot-diario.timer` file where I request the execution of one of the ***Systemd Special Units***, specifically the ***"reboot.target" Unit***, which allows a shutdown and reboot of my Linux machine.

- File `/etc/systemd/system/reboot-diario.timer`

```shell
[Unit]
Description=Reboot Diario.

[Timer]
OnCalendar=*-*-* 04:30:00
Unit=reboot.target

[Install]
WantedBy=timers.target
```

- Enable the new service

```shell
systemctl daemon-reload
systemctl enable reboot-diario.timer
systemctl start reboot-diario.timer
```

From now on, my machine will reboot every day at `04:30 am`.

<br/>

#### systemd.special

Some units are treated specially by systemd. Many of them have special internal semantics and cannot be renamed, while others simply have a standard meaning and should be present on all systems.

They exist under [systemd.special](https://man7.org/linux/man-pages/man7/systemd.special.7.html) and you can use them when needed. Here's the explanation for the one I use in this example:

- reboot.target

This is a special target for shutting down and restarting the system. Applications that want to reboot the system should not use it directly, but instead run `systemctl reboot` (possibly with the --no-block option) or call [systemd-logind(8)](https://man7.org/linux/man-pages/man8/systemd-logind.8.html)'s org.freedesktop.login1.Manager.Reboot() D-Bus method directly.

I recommend also looking into the [systemd-reboot.service(8)](https://man7.org/linux/man-pages/man8/systemd-reboot.service.8.html) service for more details on the operation this target performs.

This unit has an alias called `runlevel6.target` for SysV compatibility.
